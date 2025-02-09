//
//  VPAlarmClockSettingController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/2/18.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPAlarmClockSettingController: UIViewController , UITableViewDelegate , UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource{

    let alarmClockCellID = "alarmClockCellID"
    
    var alarmClockTableView: UITableView?
    
    var alarmPickerView: UIPickerView?
    
    var alarmModelArray: Array<VPDeviceAlarmModel> = [VPDeviceAlarmModel]()
    
    var selectModel: VPDeviceAlarmModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Alarm setting"
        view.backgroundColor = UIColor.white
        
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionData.copyBytes(to: &tbyte, count: tbyte.count)
        if tbyte[17] == 0xFE {//0xFE Indicates that there is no alarm clock on the wristband
            _ = AppDelegate.showHUD(message: "The bracelet does not have an alarm clock function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        setAlarmClockControllerUI()
        
        //The alarm clock setting is also based on the bracelet. You must read it first and then set it. The following is to read the alarm clock.
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingDeviceAlarm(withAlarmModel1: VPDeviceAlarmModel(), alarmModel2: VPDeviceAlarmModel(), alarmModel3: VPDeviceAlarmModel(), settingMode: VPOperationAlarmMode(rawValue: 6)!, successResult: { (alarmModel1, alarmModel2, alarmModel3) in
            weakSelf.alarmModelArray.append(alarmModel1!)
            weakSelf.alarmModelArray.append(alarmModel2!)
            weakSelf.alarmModelArray.append(alarmModel3!)
            weakSelf.alarmClockTableView?.reloadData()
            _ = AppDelegate.showHUD(message: "Read successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }) {
            _ = AppDelegate.showHUD(message: "Read failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
        
    }

    func setAlarmClockControllerUI() {
        alarmClockTableView = UITableView(frame: view.bounds, style: .plain)
        alarmClockTableView?.delegate = self
        alarmClockTableView?.dataSource = self
        view.addSubview(alarmClockTableView!)
        
        alarmPickerView = UIPickerView(frame: CGRect(x: 0, y: view.frame.size.height - 150, width: view.frame.size.width, height: 150))
        alarmPickerView?.backgroundColor = UIColor.white
        alarmPickerView?.delegate = self
        alarmPickerView?.dataSource = self
        view.addSubview(alarmPickerView!)
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 38)
        rightBtn.setTitle("Set up", for: .normal)
        rightBtn.setTitleColor(UIColor.blue, for: .normal)
        rightBtn.addTarget(self, action: #selector(settingAlarmAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    @objc func settingAlarmAction() {//Start setting the alarm
        //Every time you set an alarm, you must reset the three sets of alarm values
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingDeviceAlarm(withAlarmModel1: alarmModelArray[0], alarmModel2: alarmModelArray[1], alarmModel3: alarmModelArray[2], settingMode: VPOperationAlarmMode(rawValue: 1)!, successResult: { (alarmModel1, alarmModel2, alarmModel3) in
            _ = AppDelegate.showHUD(message: "Set alarm successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }) {
            _ = AppDelegate.showHUD(message: "Failed to set alarm", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
    }
    
    @objc func alarmOpenOrCloseAction(sender:UISwitch) {
        let alarmModel = alarmModelArray[sender.tag]
        alarmModel.alarmState = sender.isOn ? 1 : 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: alarmClockCellID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: alarmClockCellID)
        }
        
        let alarmClockSwitch = UISwitch()
        
        alarmClockSwitch.tag = indexPath.row
        
        alarmClockSwitch.addTarget(self, action: #selector(alarmOpenOrCloseAction(sender:)), for: .touchUpInside)
        
        alarmClockSwitch.isOn = false//为1即为开
        
        cell?.accessoryView = alarmClockSwitch
        cell?.accessoryType = .disclosureIndicator
        
        guard alarmModelArray.count == 3 else {
            cell?.textLabel?.text = "Alarm clock" + String(indexPath.row + 1)
            alarmClockSwitch.isEnabled = false//为1即为开
            return cell!
        }
        
        let alarmModel = alarmModelArray[indexPath.row]
        
        cell?.textLabel?.text = "Alarm clock" + String(indexPath.row + 1) + ": " + String.init(format: "%02u", alarmModel.alarmHour) + ":" + String.init(format: "%02u", alarmModel.alarmMinute)
        alarmClockSwitch.isOn = alarmModel.alarmState == 1
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard alarmModelArray.count == 3 else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        selectModel = alarmModelArray[indexPath.row]
        
        guard let model = selectModel else {
            
            return
        }
        
        alarmPickerView?.selectRow(Int(model.alarmHour), inComponent: 0, animated: false)
        alarmPickerView?.selectRow(Int(model.alarmMinute), inComponent: 1, animated: false)
    }
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 24
        }
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let model = selectModel else {
            return
        }
        if component == 0 {
            model.alarmHour = UInt(row)
        }else {
            model.alarmMinute = UInt(row)
        }
        alarmClockTableView?.reloadData()
    }
    
}

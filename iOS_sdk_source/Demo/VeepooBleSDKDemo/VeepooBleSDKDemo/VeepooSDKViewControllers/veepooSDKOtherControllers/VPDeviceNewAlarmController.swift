//
//  VPDeviceNewAlarmController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/6/16.
//  Copyright © 2017年 zc.All rights reserved.
//

/*
 The new alarm clock can be set up to 20 groups. When you are doing it, you will be reminded not to continue adding it when it exceeds 20 groups.
    The sorting method of alarm clocks stored on the device is sorted according to the ID of the model. The SDK returns the order set by the user (if the user uninstalls the App, the first read sort is the same as the device side)
   
    What I show here does not distinguish between single and repeated weeks. During development, you can display the repeated and single in two areas. You can refer to our H Band. When re-dividing, perform the returned array Just deal with it, I won’t say more here
 */

//This demo compiles the logic of all alarm clocks, including adding, deleting, modifying and checking, and sliding can be deleted. In the 1.7 version, I was lazy for a single date selection. First, I only write a random one. The developer can understand what it means, and I am a little tired of writing 😰 , The next version has time to write all the logic, depending on the mood 😀
import UIKit

class VPDeviceNewAlarmController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let deviceNewAlarmCellID = "newAlarmCellID"
    
    var deviceNewAlarmTableView: UITableView?
    
    var deviceAlarmArray = Array<Any>()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New alarm setting"
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        self.setDeviceNewAlarmControllerUI()
        
        if VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionData == nil {
            _ = AppDelegate.showHUD(message: "The bracelet has no new alarm function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionData.copyBytes(to: &tbyte, count: tbyte.count)
        if !(tbyte[17] != 1 || tbyte[17] != 2 || tbyte[17] != 3 || tbyte[17] != 4) {//First judge whether it has this function
            _ = AppDelegate.showHUD(message: "The bracelet has no new alarm function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        //First read the alarm clock of the device
        self.readOrSettingAlarmClock(settingAlarmModel: VPDeviceNewAlarmModel(), settingMode: 2)
    }

    func setDeviceNewAlarmControllerUI() {
        deviceNewAlarmTableView = UITableView(frame: view.bounds, style: .plain)
        deviceNewAlarmTableView?.delegate = self
        deviceNewAlarmTableView?.dataSource = self
        deviceNewAlarmTableView?.tableFooterView = UIView()
        view.addSubview(deviceNewAlarmTableView!)
        
        deviceNewAlarmTableView?.register(UINib.init(nibName: "VPNewAlarmCell", bundle: Bundle.main), forCellReuseIdentifier: deviceNewAlarmCellID)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlarmClock))
    }
    
    @objc func openOrCloseAlarmClock(sender: UISwitch) {//Turn on or off a single set of alarms, only valid for alarms that repeat the week
        let alarmModel = deviceAlarmArray[sender.tag] as? VPDeviceNewAlarmModel
        //Copy a model below, so as not to change the model after the setting fails, the page cannot be refreshed to the correct state
        let settingModel = alarmModel?.copy() as? VPDeviceNewAlarmModel
        settingModel?.alarmState = sender.isOn ? "1" : "0"
        
        self.readOrSettingAlarmClock(settingAlarmModel: settingModel!, settingMode: 1)
    }
    
    @objc func addAlarmClock()  {//
        if deviceAlarmArray.count >= 20 {
            _ = AppDelegate.showHUD(message: "The device supports up to 20 groups of alarms", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        let editController = VPEditNewAlarmController(nibName: "VPEditNewAlarmController", bundle: Bundle.main)
        editController.isAdd = true
        //The initialized Model, the time and ID in the SDK have been defaulted
        let addAlarmModel = VPDeviceNewAlarmModel()
        editController.alarmModel = addAlarmModel
        unowned let weakSelf = self
        editController.callBackBlock = {() -> Void in
            weakSelf.readOrSettingAlarmClock(settingAlarmModel: addAlarmModel, settingMode: 1)
        }
        navigationController?.pushViewController(editController, animated: true)
    }

    func readOrSettingAlarmClock(settingAlarmModel: VPDeviceNewAlarmModel, settingMode:UInt) {//Set or read a new alarm
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingDeviceNewAlarm(with: settingAlarmModel, settingMode: settingMode, successResult: { (alarmArray) in
            print(alarmArray?.count ?? "")
            weakSelf.deviceAlarmArray = alarmArray!
            weakSelf.deviceNewAlarmTableView?.reloadData()
            var tip = "Read successfully"
            if settingMode == 0 {
                tip = "Successfully deleted"
            }else if settingMode == 1 {
                tip = "Set successfully"
            }
            _ = AppDelegate.showHUD(message: tip, hudModel: MBProgressHUDModeText, showView: UIApplication.shared.keyWindow!)
            if weakSelf.navigationController?.topViewController is VPEditNewAlarmController {
                _ = weakSelf.navigationController?.popViewController(animated: true)
            }
        }) {
            var tip = "Read failed"
            if settingMode == 0 {
                tip = "Failed to delete"
            }else if settingMode == 1 {
                tip = "Setup failed"
            }
            _ = AppDelegate.showHUD(message: tip, hudModel: MBProgressHUDModeText, showView: UIApplication.shared.keyWindow!)
            weakSelf.deviceNewAlarmTableView?.reloadData()
        }
    }

    //MARK: tableView的代理
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceAlarmArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VPNewAlarmCell = tableView.dequeueReusableCell(withIdentifier: deviceNewAlarmCellID, for: indexPath) as! VPNewAlarmCell
        cell.alarmModel = deviceAlarmArray[indexPath.row] as? VPDeviceNewAlarmModel
        cell.alarmSwitch.addTarget(self, action: #selector(openOrCloseAlarmClock(sender:)), for: .valueChanged)
        cell.alarmSwitch.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let editController = VPEditNewAlarmController(nibName: "VPEditNewAlarmController", bundle: Bundle.main)
        let modifyAlarmModel = deviceAlarmArray[indexPath.row] as? VPDeviceNewAlarmModel
        let copyModel = modifyAlarmModel?.copy() as! VPDeviceNewAlarmModel?
        editController.alarmModel = copyModel
        unowned let weakSelf = self
        editController.callBackBlock = {() -> Void in
            weakSelf.readOrSettingAlarmClock(settingAlarmModel: copyModel!, settingMode: 1)
        }
        navigationController?.pushViewController(editController, animated: true)
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let delectAlarmModel = deviceAlarmArray[indexPath.row] as? VPDeviceNewAlarmModel
            let copyModel = delectAlarmModel?.copy() as! VPDeviceNewAlarmModel?
            self.readOrSettingAlarmClock(settingAlarmModel: copyModel!, settingMode: 0)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

}

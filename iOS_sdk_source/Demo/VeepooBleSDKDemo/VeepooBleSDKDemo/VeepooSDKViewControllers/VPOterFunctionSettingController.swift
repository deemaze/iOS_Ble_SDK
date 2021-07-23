//
//  VPOterFunctionSettingController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/2/17.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPOterFunctionSettingController: UIViewController   , UITableViewDelegate , UITableViewDataSource{

    let otherFunctionSettingCellID = "otherFunctionSettingCellID"
    
    var otherFunctionSettingTableView: UITableView?
    
    let otherFunctions = ["Sync personal information","Alarm setting","Blood pressure private mode setting","Sedentary reminder settings","Heart rate alarm settings","camera function","Pair with phone","Turn your wrist to bright screen","Change Password", "Brightness Adjustment", "Female Setting", "Countdown Function", "New Alarm Setting", "Color Screen Style Setting", "Bright Screen Duration", "Tap Test", "Photo Dial"," Market dial", "Mobile phone search bracelet", "GPS and time zone settings", "Body temperature data reading"]
    
    let otherControllers = ["VPSyncPersonalInformationController","VPAlarmClockSettingController","VPBloodPrivateSettingController","VPLongSeatSettingController","VPHeartAlarmController","VPTakePhotoController","与手机配对","VPRaiseHandSettingController","VPModifyPasswordController","VPSettingBrightController","VPSettingFemaleRelatedController","VPDeviceCountDownController","VPDeviceNewAlarmController","VPSettingScreenStyleController","VPSettingScreenDurationController","VPTapTestViewController","VPPhotoDialViewController","VPMarketDialViewController","VPFindDeviceViewController","VPSettingDeviceGPSViewController", "VPTemperatureViewController"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "function list"
        view.backgroundColor = UIColor.white
        otherFunctionSettingTableView = UITableView(frame: view.bounds, style: .plain)
        otherFunctionSettingTableView?.autoresizingMask = UIViewAutoresizing.flexibleHeight
        otherFunctionSettingTableView?.delegate = self
        otherFunctionSettingTableView?.dataSource = self
        view.addSubview(otherFunctionSettingTableView!)
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
    }

    func settingBaseFunctionRemindFarilure(sender: UISwitch) {
        sender.isOn = !sender.isOn
    }
    
    //MARK: tableView的代理
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherFunctions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: otherFunctionSettingCellID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: otherFunctionSettingCellID)
        }
        cell?.textLabel?.text = otherFunctions[indexPath.row]
        
        cell?.accessoryType = .disclosureIndicator
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 6 {//手机配对，如果已经配对了点击没有反应，如果没有配对，系统会有弹窗询问用户是否需要配对
            VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSendPairedWithIphoneCommand()
            return
        }
        let controllerName = otherControllers[indexPath.row]
        
        let controllerClass: AnyClass? = NSClassFromString(nameSpace + "." + controllerName)
        
        let controller = controllerClass as! UIViewController.Type
        
        self.navigationController?.pushViewController(controller.init(), animated: true)
    }
}







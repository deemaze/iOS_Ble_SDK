//
//  VPBloodPrivateSettingController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/2/17.
//  Copyright © 2017年 zc.All rights reserved.
//

/*
 SDK1.7之后对此模块进行修改，因设备区别，有的是直接设置私人模式，有的需要动态校准，如果需要动态校准的设备，在动态校准过程中要保持正确的佩戴姿势，动态校准时间比较长，如果快的话30秒之内，如果慢的话大概要1-2分钟
    .7 After this module is modified, due to the difference of the equipment, some are directly set to the private mode, and some require dynamic calibration. If the equipment needs to be dynamically calibrated, the correct wearing posture must be maintained during the dynamic calibration process. The dynamic calibration time is relatively long. If it's fast, within 30 seconds, if it's slow, it's probably 1-2 minutes
 */

import UIKit

class VPBloodPrivateSettingController: UIViewController {

    @IBOutlet weak var systolicLabel: UILabel!
    
    @IBOutlet weak var diastolicLabel: UILabel!
    
    @IBOutlet weak var modeLabel: UILabel!
    
    @IBOutlet weak var systolicSlider: UISlider!
    
    @IBOutlet weak var diastolicSlider: UISlider!
    
    @IBOutlet weak var bloodModeSegControl: UISegmentedControl!
    
    @IBOutlet weak var bloodSettingBtn: UIButton!
    
    @IBOutlet weak var calibrationProgressLabel: UILabel!
    
    var isNew:Bool = false //Whether it is dynamic calibration
    
    var privateBloodModel: VPDevicePrivateBloodModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Blood pressure private mode setting"
        
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionData.copyBytes(to: &tbyte, count: tbyte.count)
        if tbyte[1] != 1 {//First judge whether it has this function
            _ = AppDelegate.showHUD(message: "The bracelet does not have this function", hudModel: MBProgressHUDModeText, showView: view)
            bloodSettingBtn.isEnabled = false
            return
        }
        
        if tbyte[16] == 1 {//If it is equal to one, it is necessary to use dynamic calibration, otherwise it is the normal mode setting
            bloodSettingBtn.setTitle("Dynamic calibration", for: .normal)
            bloodSettingBtn.setTitle("Dynamic calibration", for: .disabled)
            calibrationProgressLabel.isHidden = false
            isNew = true
        }
        
        //要先读取一下手环的数据，这个App显示一般以手环为主
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingPersonalBlood(with: VPDevicePrivateBloodModel(), settingMode: .readFunctionState, successResult: { (devicePrivateModel) in
            weakSelf.privateBloodModel = devicePrivateModel
            if devicePrivateModel?.systolicPressure == 0 && devicePrivateModel?.diastolicPressure == 0 {
                _ = AppDelegate.showHUD(message: "The bracelet has not set this function", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            }else {//展示给用户当前手环的值
                _ = AppDelegate.showHUD(message: "Read blood pressure private mode successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                weakSelf.systolicSlider.value = Float((devicePrivateModel?.systolicPressure)!)
                weakSelf.diastolicSlider.value = Float((devicePrivateModel?.diastolicPressure)!)
                weakSelf.bloodModeSegControl.selectedSegmentIndex = Int((devicePrivateModel?.privateMode)!)
                weakSelf.systolicLabel.text = "high pressure:" + String((devicePrivateModel?.systolicPressure)!)
                weakSelf.diastolicLabel.text = "Low pressure:" + String((devicePrivateModel?.diastolicPressure)!)
                weakSelf.modeLabel.text = devicePrivateModel?.privateMode == 0 ? "Mode: General" : "Mode: Private"
            }
        }) { 
            _ = AppDelegate.showHUD(message: "Failed to read blood pressure private mode", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isNew == false {//If not, no need to cancel
            return
        }
        //Cancel dynamic calibration when exiting the interface, and it can also be canceled during calibration
//        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingPersonalBlood(with: privateBloodModel, settingMode: .settingFunctionCancel, successResult: { (devicePrivateModel) in
//            guard let devicePrivateModel = devicePrivateModel else {
//                return
//            }
            
        }) {
        }
    }

    @IBAction func settingBloodValueAction(_ sender: UISlider) {
        let bloodValue = UInt16(sender.value)
        if sender.tag == 0 {
            systolicLabel.text = "High pressure:" + String(bloodValue)
        }else {
            diastolicLabel.text = "Low pressure:" + String(bloodValue)
        }
    }
    
    @IBAction func choiceBloodTestModeAction(_ sender: UISegmentedControl) {
        modeLabel.text = bloodModeSegControl.selectedSegmentIndex == 0 ? "Mode: General" : "Mode: Private"
    }
    
    @IBAction func startSettingBloodModeAction(_ sender: UIButton) {
        sender.isEnabled = false
        privateBloodModel?.systolicPressure = UInt(systolicSlider.value)
        privateBloodModel?.diastolicPressure = UInt(diastolicSlider.value)
        privateBloodModel?.privateMode = UInt(bloodModeSegControl.selectedSegmentIndex)
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingPersonalBlood(with: privateBloodModel, settingMode: .settingFunction, successResult: { (devicePrivateModel) in
            guard let devicePrivateModel = devicePrivateModel else {
                return
            }
            if devicePrivateModel.settingState == 1 {//Ordinary private settings
                _ = AppDelegate.showHUD(message: "Set blood pressure private mode successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                sender.isEnabled = true
            }else if devicePrivateModel.settingState == 6 {//Dynamic calibration
                weakSelf.calibrationProgressLabel.text = "Dynamic calibration progress:" + String(describing: devicePrivateModel.calibrationProgress) + "%"
            }else if devicePrivateModel.settingState == 7 {//Dynamic calibration
                _ = AppDelegate.showHUD(message: "Dynamic calibration failed, please try again", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                sender.isEnabled = true
            }else if devicePrivateModel.settingState == 8 {//Dynamic calibration
                _ = AppDelegate.showHUD(message: "Dynamic calibration succeeded", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                weakSelf.calibrationProgressLabel.text = "Dynamic calibration progress:100%"
                sender.isEnabled = true
            }else if devicePrivateModel.settingState == 9 {//The device is operating, calibration failed
                sender.isEnabled = true
                _ = AppDelegate.showHUD(message: "Calibration failed, please do not operate the device during calibration", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            }
            
        }) {
            sender.isEnabled = true
            _ = AppDelegate.showHUD(message: "Failed to set blood pressure private mode", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
    }
    
}









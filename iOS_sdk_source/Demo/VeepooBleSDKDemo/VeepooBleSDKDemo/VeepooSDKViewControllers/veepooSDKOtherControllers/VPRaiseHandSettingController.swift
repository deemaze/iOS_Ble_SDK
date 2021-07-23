//
//  VPRaiseHandSettingController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/3/2.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPRaiseHandSettingController: UIViewController {

    @IBOutlet weak var startHourLabel: UILabel!
    
    @IBOutlet weak var startMinuteLabel: UILabel!
    
    @IBOutlet weak var endHourLabel: UILabel!
    
    @IBOutlet weak var endMinuteLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var startHourSlider: UISlider!
    
    @IBOutlet weak var startMinuteSlider: UISlider!
    
    @IBOutlet weak var endHourSlider: UISlider!
    
    @IBOutlet weak var endMinuteSlider: UISlider!
    
    @IBOutlet weak var stateSegControl: UISegmentedControl!
    
    @IBOutlet var sensitiveLabel: UILabel!
    
    @IBOutlet var sensitiveSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Turn your wrist to bright screen"
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionData.copyBytes(to: &tbyte, count: tbyte.count)
        if tbyte[11] != 1 {//First judge whether it has this function
            _ = AppDelegate.showHUD(message: "The bracelet does not have the function of turning the wrist to brighten the screen", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        //At the beginning, you need to read the bracelet first. The display on the App is based on the bracelet, and there must be a model for reading. As long as there is a model, it cannot be nil.
        let raiseHandModel = VPDeviceRaiseHandModel()
        //开始读取
        unowned let weakSelf = self;
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingRaiseHand(with: raiseHandModel, settingMode: 2, successResult: { (raiseHandModel) in
            guard let readRaiseHandModel = raiseHandModel else {
                print("error")
                return
            }
            //如果默认灵敏度为零，就没有灵敏度调试功能，早期的手环都没有这个功能
            weakSelf.sensitiveLabel.isHidden = readRaiseHandModel.defaultSensitive == 0
            weakSelf.sensitiveSlider.isHidden = weakSelf.sensitiveLabel.isHidden
            
            _ = AppDelegate.showHUD(message: "Read successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            weakSelf.startHourLabel.text = "Start hour:" + String(describing: readRaiseHandModel.raiseHandStartHour)
            
            weakSelf.startMinuteLabel.text = "Start minute:" + String(describing: readRaiseHandModel.raiseHandStartMinute)
            
            weakSelf.endHourLabel.text = "End hour:" + String(describing: readRaiseHandModel.raiseHandEndHour)
            
            weakSelf.endMinuteLabel.text = "End minute:" + String(describing: readRaiseHandModel.raiseHandEndMinute)
            
            weakSelf.stateLabel.text = readRaiseHandModel.raiseHandState == 0 ? "Status: Off" : "Status: On"
            
            weakSelf.sensitiveLabel.text = "Sensitivity:" + String(describing: readRaiseHandModel.sensitive)
            
            weakSelf.startHourSlider.value = Float(readRaiseHandModel.raiseHandStartHour)
            
            weakSelf.startMinuteSlider.value = Float(readRaiseHandModel.raiseHandStartMinute)
            
            weakSelf.endHourSlider.value = Float(readRaiseHandModel.raiseHandEndHour)
            
            weakSelf.endMinuteSlider.value = Float(readRaiseHandModel.raiseHandEndMinute)
            
            weakSelf.stateSegControl.selectedSegmentIndex = Int(readRaiseHandModel.raiseHandState)
            
            weakSelf.sensitiveSlider.value = Float(readRaiseHandModel.sensitive)
            
        }) { 
            _ = AppDelegate.showHUD(message: "Read failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
        
        // Do any additional setup after loading the view.
    }

    @IBAction func sliderValueChangedAction(_ sender: UISlider) {
        let sliderValue = UInt16(sender.value)
        switch sender.tag {
        case 0:
            startHourLabel.text = "Start hour:" + String(sliderValue)
        case 1:
            startMinuteLabel.text = "Start minute:" + String(sliderValue)
        case 2:
            endHourLabel.text = "End hour:" + String(sliderValue)
        case 3:
            endMinuteLabel.text = "End minute:" + String(sliderValue)
        case 4:
            sensitiveLabel.text = "Sensitivity:" + String(sliderValue)
        default:
            print("error")
        }
    }
    
    @IBAction func stateChangedAction(_ sender: UISegmentedControl) {
        stateLabel.text = stateSegControl.selectedSegmentIndex == 0 ? "Status: Off" : "Status: On"
    }
    
    @IBAction func startSettingLongseatAction(_ sender: UIButton) {
        //建立久坐模型
        let raiseHandModel = VPDeviceRaiseHandModel(raiseHandStartHour: UInt(startHourSlider.value), raiseHandStartMinute: UInt(startMinuteSlider.value), raiseHandEndHour: UInt(endHourSlider.value), raiseHandEndMinute: UInt(endMinuteSlider.value), raiseHandState: UInt(stateSegControl.selectedSegmentIndex), raiseHandSensitive: UInt(sensitiveSlider.value))
        
        //开始设置
        unowned let weakSelf = self;
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingRaiseHand(with: raiseHandModel, settingMode: UInt(stateSegControl.selectedSegmentIndex), successResult: { (raiseHandModel) in
            _ = AppDelegate.showHUD(message: "Flip the wrist and the bright screen is set successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }) { 
            _ = AppDelegate.showHUD(message: "Failed to set the bright screen on the wrist", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
    }

}

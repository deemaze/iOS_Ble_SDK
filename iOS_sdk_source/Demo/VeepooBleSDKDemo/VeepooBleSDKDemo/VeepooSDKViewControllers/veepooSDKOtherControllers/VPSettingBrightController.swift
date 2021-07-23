//
//  VPSettingBrightController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/3/10.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPSettingBrightController: UIViewController {

    @IBOutlet weak var brightStartHourLabel: UILabel!
    @IBOutlet weak var brightStartMinuteLabel: UILabel!
    @IBOutlet weak var brightEndHourLabel: UILabel!
    @IBOutlet weak var brightEndMinuteLabel: UILabel!
    @IBOutlet weak var firstBrightValueLabel: UILabel!
    @IBOutlet weak var otherBrightValueLabel: UILabel!
    @IBOutlet weak var brightStartHourSlider: UISlider!
    @IBOutlet weak var brightStartMinuteSlider: UISlider!
    @IBOutlet weak var brightEndHourSlider: UISlider!
    @IBOutlet weak var brightEndMinuteSlider: UISlider!
    @IBOutlet weak var firstBrightValueSlider: UISlider!
    @IBOutlet weak var otherBrightValueSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Brightness adjustment settings"
        
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage
            .sharedBleManager().peripheralModel.deviceFuctionData.copyBytes(to: &tbyte, count: tbyte.count)
        if tbyte[13] != 1 {//先判断一下是否有这个功能
            _ = AppDelegate.showHUD(message: "The bracelet has no brightness adjustment function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        //At the beginning, you need to read the bracelet first. The display on the App is based on the bracelet, and there must be a model for reading. As long as there is a model, it cannot be nil.
        let brightModel = VPDeviceBrightModel()
        
        //开始读取
        unowned let weakSelf = self;
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingBright(with: brightModel, settingMode: 2, successResult: { (deviceBrightModel) in
            guard let readBrightModel = deviceBrightModel else {
                print("error")
                return
            }
            _ = AppDelegate.showHUD(message: "Read successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            weakSelf.firstBrightValueSlider.value = Float(readBrightModel.maxBrightValue)
            weakSelf.otherBrightValueSlider.value = Float(readBrightModel.maxBrightValue)
            weakSelf.brightStartHourLabel.text = "Start hour:" + String(describing: readBrightModel.firstBrightStartHour)
            weakSelf.brightStartHourSlider.value = Float(readBrightModel.firstBrightStartHour)
            
            weakSelf.brightStartMinuteLabel.text = "Start minute:" + String(describing: readBrightModel.firstBrightStartMinute)
            weakSelf.brightStartMinuteSlider.value = Float(readBrightModel.firstBrightStartMinute)
            
            weakSelf.brightEndHourLabel.text = "End hour:" + String(describing: readBrightModel.firstBrightEndHour)
            weakSelf.brightEndHourSlider.value = Float(readBrightModel.firstBrightEndHour)
            
            weakSelf.brightEndMinuteLabel.text = "End minute:" + String(describing: readBrightModel.firstBrightEndMinute)
            weakSelf.brightEndMinuteSlider.value = Float(readBrightModel.firstBrightEndMinute)
            
            weakSelf.firstBrightValueLabel.text = "First brightness:" + String(describing: readBrightModel.firstBrightValue)
            weakSelf.firstBrightValueSlider.value = Float(readBrightModel.firstBrightValue)
            
            weakSelf.otherBrightValueLabel.text = "Other gears:" + String(describing: readBrightModel.otherBrightValue)
            
            weakSelf.otherBrightValueSlider.value = Float(readBrightModel.otherBrightValue)
        }) {
            _ = AppDelegate.showHUD(message: "Read failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func sliderValueChangedAction(_ sender: UISlider) {
        let sliderValue = UInt16(sender.value)
        switch sender.tag {
        case 0:
            brightStartHourLabel.text = "Start hour:" + String(sliderValue)
        case 1:
            brightStartMinuteLabel.text = "Start minute:" + String(sliderValue)
        case 2:
            brightEndHourLabel.text = "End hour:" + String(sliderValue)
        case 3:
            brightEndMinuteLabel.text = "End minute:" + String(sliderValue)
        case 4:
            firstBrightValueLabel.text = "First brightness:" + String(sliderValue)
        case 5:
            otherBrightValueLabel.text = "Other gears:" + String(sliderValue)
        default:
            print("error")
        }
    }
    
    @IBAction func startSettingLongseatAction(_ sender: UIButton) {
        //建立亮度调节模型
        let brightModel = VPDeviceBrightModel(startHour: Int(brightStartHourSlider.value), startMinute: Int(brightStartMinuteSlider.value), endHour: Int(brightEndHourSlider.value), endMinute: Int(brightEndMinuteSlider.value), firstBrightValue: Int(firstBrightValueSlider.value), otherBrightValue: Int(otherBrightValueSlider.value))
        
        //开始设置
        unowned let weakSelf = self;
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingBright(with: brightModel, settingMode: 1, successResult: { (deviceBrightModel) in
            _ = AppDelegate.showHUD(message: "Brightness adjustment set successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }) { 
            _ = AppDelegate.showHUD(message: "Brightness adjustment setting failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



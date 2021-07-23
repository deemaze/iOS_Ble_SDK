//
//  VPLongSeatSettingController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/2/17.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPLongSeatSettingController: UIViewController {

    @IBOutlet weak var startHourLabel: UILabel!
    
    @IBOutlet weak var startMinuteLabel: UILabel!
    
    @IBOutlet weak var endHourLabel: UILabel!
    
    @IBOutlet weak var endMinuteLabel: UILabel!
    
    @IBOutlet weak var howLongRemindLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var startHourSlider: UISlider!
    
    @IBOutlet weak var startMinuteSlider: UISlider!
    
    @IBOutlet weak var endHourSlider: UISlider!
    
    @IBOutlet weak var endMinuteSlider: UISlider!
    
    @IBOutlet weak var howLongRemindSlider: UISlider!
    
    @IBOutlet weak var stateSegControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sedentary reminder settings"
        
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionData.copyBytes(to: &tbyte, count: tbyte.count)
        if tbyte[3] != 1 {//First judge whether it has this function
            _ = AppDelegate.showHUD(message: "The bracelet does not have a sedentary function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        //At the beginning, you need to read the bracelet first. The display on the App is based on the bracelet, and there must be a model for reading. As long as there is a model, it cannot be nil.
        let longSeatModel = VPDeviceLongSeatModel()
        //Start reading
        unowned let weakSelf = self;
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingDeviceLongSeat(with: longSeatModel, settingMode: 2, successResult: { (longSeatModel) in
            
            guard let readLongSeatModel = longSeatModel else {
                print("error")
                return
            }
            _ = AppDelegate.showHUD(message: "Read successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            weakSelf.startHourLabel.text = "Start hour:" + String(describing: readLongSeatModel.longSeatStartHour)
            
            weakSelf.startMinuteLabel.text = "Start minute:" + String(describing: readLongSeatModel.longSeatStartMinute)
           
            weakSelf.endHourLabel.text = "End hour:" + String(describing: readLongSeatModel.longSeatEndHour)
            
            weakSelf.endMinuteLabel.text = "End minute:" + String(describing: readLongSeatModel.longSeatEndMinute)
           
            weakSelf.howLongRemindLabel.text = "How often to remind:" + String(describing: readLongSeatModel.longSeatGateValue)
            
            weakSelf.stateLabel.text = readLongSeatModel.longSeatState == 0 ? "Status: Off" : "Status: On"
            
            weakSelf.startHourSlider.value = Float(readLongSeatModel.longSeatStartHour)
            
            weakSelf.startMinuteSlider.value = Float(readLongSeatModel.longSeatStartMinute)
            
            weakSelf.endHourSlider.value = Float(readLongSeatModel.longSeatEndHour)
            
            weakSelf.endMinuteSlider.value = Float(readLongSeatModel.longSeatEndMinute)
            
            weakSelf.howLongRemindSlider.value = Float(readLongSeatModel.longSeatGateValue) / 30
            
            weakSelf.stateSegControl.selectedSegmentIndex = Int(readLongSeatModel.longSeatState)
            
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
            howLongRemindLabel.text = "How often to remind:" + String(sliderValue * 30)
        default:
            print("error")
        }
    }
    
    @IBAction func stateChangedAction(_ sender: UISegmentedControl) {
        stateLabel.text = stateSegControl.selectedSegmentIndex == 0 ? "Status: Off" : "Status: On"
    }
    
    @IBAction func startSettingLongseatAction(_ sender: UIButton) {
        //建立久坐模型
        let longSeatModel = VPDeviceLongSeatModel(longSeatStartHour: UInt(startHourSlider.value), longSeatStartMinute: UInt(startMinuteSlider.value), longSeatEndHour: UInt(endHourSlider.value), longSeatEndMinute: UInt(endMinuteSlider.value), longSeatGateValue: UInt(howLongRemindSlider.value) * 30, longSeatState: UInt(stateSegControl.selectedSegmentIndex))
        
        //开始设置
        unowned let weakSelf = self;
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingDeviceLongSeat(with: longSeatModel, settingMode: UInt(stateSegControl.selectedSegmentIndex), successResult: { (longSeatModel) in
            _ = AppDelegate.showHUD(message: "Sedentary set up successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }) {
            _ = AppDelegate.showHUD(message: "Sedentary setup failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
    }
}





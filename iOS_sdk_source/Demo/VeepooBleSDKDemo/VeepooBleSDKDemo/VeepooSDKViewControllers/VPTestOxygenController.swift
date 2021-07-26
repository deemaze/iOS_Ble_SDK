//
//  VPTestOxygenController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/3/3.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPTestOxygenController: UIViewController {

    @IBOutlet weak var currentOxygenValueLabel: UILabel!
    @IBOutlet weak var currentRateValueLabel: UILabel!
    
    @IBOutlet weak var testOxygenBtn: UIButton!
    @IBOutlet weak var testRateBtn: UIButton!
    
    @IBOutlet weak var oxygenDateLabel: UILabel!
    
    // Graph to display oxygen data
    var oxygenCurview = VPOxygenCurveView()
    
    // Index to the current day
    var oxygenDayIndex = 0
    
    var y: CGFloat = 0.0
    var width: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SpO2"
        
        // Do any additional setup after loading the view.
        y = self.view.bounds.size.height
        width = UIScreen.main.bounds.width
        
        getOneDayOxygenData()
    }
    
    func getOneDayOxygenData() {
        
        oxygenCurview.removeFromSuperview()
        
        self.oxygenDateLabel.text = oxygenDayIndex.getOneDayDateString()
        let arr = VPDataBaseOperation.veepooSDKGetDeviceOxygenData(withDate: self.oxygenDateLabel.text, andTableID: VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress)
        //let arr = VPDataBaseOperation.veepooSDKGetDeviceOxygenData(withDate: "2020-05-27", andTableID: "FF:E4:71:43:BC:D9")
        
        oxygenCurview = VPOxygenCurveView(vpOxygenCurveType:VPOxygenCurveTypeOxygen)
        
        oxygenCurview.frame = CGRect(x: 0, y: y - 200, width: width, height: 300)
        
        oxygenCurview.oneDayOxygens = arr
        
        view.addSubview(oxygenCurview)
    }
    
    @IBAction func obtainLastDataAction(_ sender: Any) {
        oxygenDayIndex = oxygenDayIndex - 1
        getOneDayOxygenData()
    }
    
    @IBAction func obtainNextDataAction(_ sender: Any) {
        oxygenDayIndex = oxygenDayIndex + 1
        getOneDayOxygenData()
    }
    
    @IBAction func startTestOxygenAction(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//        VPBleCentralManage.sharedBleManager()
//            .peripheralManage.veepooSDKTestECGStart(sender.isSelected) { (state, progress1, model) in
//
//        }
//
//        return
        
        if VPBleCentralManage.sharedBleManager().peripheralModel.oxygenType == 0 {//先判断一下是否有这个功能
            _ = AppDelegate.showHUD(message: "The bracelet has no blood oxygen function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            currentOxygenValueLabel.text = "Current blood oxygen level: "
        }
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKTestOxygenStart(sender.isSelected) { (testOxygenState, oxygenValue) in
            if  sender.isSelected {
                switch testOxygenState {
                case .start:
                    _ = AppDelegate.showHUD(message: "Preparing for the test, please keep the correct posture", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                case .testing: //正在检测血氧，已经测出血氧值
                    weakSelf.currentOxygenValueLabel.text = "Current blood oxygen level:" + String(oxygenValue) + "%"
                case .notWear: //佩戴检测没有通过，测试已经结束
                    _ = AppDelegate.showHUD(message: "Wearing test failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .deviceBusy: //设备正忙不能测试了，测试已经结束
                    _ = AppDelegate.showHUD(message: "Device side is operating", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .over: //测试正常结束，人为结束
                    _ = AppDelegate.showHUD(message: "End of test", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .noFunction: //设备没有此功能
                    _ = AppDelegate.showHUD(message: "The device does not have this function", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .calibration: //校准中
                    weakSelf.currentOxygenValueLabel.text = "Calibration progress:" + String(oxygenValue) + "%"
                case .calibrationComplete: //校准完成
                    weakSelf.currentOxygenValueLabel.text = "Calibration progress:" + String(oxygenValue) + "%"
                default:
                    break
                }
            }else {
                if testOxygenState == .over {
                    _ = AppDelegate.showHUD(message: "End of test", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                }
            }
        }
    }
    
    @IBAction func startTestRateAction(_ sender: UIButton) {//开始测试呼吸率
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionDataTwo.copyBytes(to: &tbyte, count: tbyte.count)
        if tbyte[7] != 1 {//先判断一下是否有这个功能
            _ = AppDelegate.showHUD(message: "The bracelet has no breath rate function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        sender.isSelected = !sender.isSelected
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKTestBreathingRateStart(sender.isSelected) { (testBreathingRateState, testProgress, testValue) in
            if  sender.isSelected {
                switch testBreathingRateState {
                case .start:
                    _ = AppDelegate.showHUD(message: "Preparing for the test, please keep the correct posture", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                case .testing: //正在检测呼吸率
                    weakSelf.currentRateValueLabel.text = "Test progress:" + String(testProgress) + "%"
                case .notWear: //佩戴检测没有通过，测试已经结束
                    weakSelf.currentOxygenValueLabel.text = "Wearing test failed"
                    sender.isSelected = false
                case .deviceBusy: //设备正忙不能测试了，测试已经结束
                    weakSelf.currentRateValueLabel.text = "Device side is operating"
                    sender.isSelected = false
                case .over: //测试正常结束，人为结束
                    weakSelf.currentRateValueLabel.text = "End of test"
                    sender.isSelected = false
                case .complete: //正常完成
                    weakSelf.currentRateValueLabel.text = "Respiration rate:" + String(testValue) + "%" + "Times/min"
                    sender.isSelected = false
                case .failure: //测试无效
                    weakSelf.currentRateValueLabel.text = "Invalid test"
                    sender.isSelected = false
                case .noFunction: //设备没有此功能
                    weakSelf.currentRateValueLabel.text = "The device does not have this function"
                    sender.isSelected = false
                }
            }else {
                if testBreathingRateState == .over {
                    weakSelf.currentRateValueLabel.text = "End of test"
                }
            }
        }
    }
    
    deinit {//销毁的时候关闭血氧测试
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKTestOxygenStart(false, testResult: nil)
    }

}

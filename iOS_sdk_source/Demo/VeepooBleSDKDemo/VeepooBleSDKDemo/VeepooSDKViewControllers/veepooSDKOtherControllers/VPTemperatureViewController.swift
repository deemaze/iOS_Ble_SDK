//
//  VPTemperatureViewController.swift
//  VeepooBleSDKDemo
//
//  Created by veepoo-cd on 2021/6/5.
//  Copyright © 2021 veepoo. All rights reserved.
//

import UIKit

class VPTemperatureViewController: UIViewController {

    @IBOutlet weak var supportFunctionLabel: UILabel!
    @IBOutlet weak var readAutoTestDataBtn: UIButton!
    @IBOutlet weak var manualTestDataBtn: UIButton!
    @IBOutlet weak var monitorSwitch: UISwitch!
    
    var support: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Body temperature data reading"
        support = VPBleCentralManage.sharedBleManager()?.peripheralModel.temperatureType != 0
        supportFunctionLabel.text = support ? "Yes" : "No"
        
        if support {
            VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDKSettingBaseFunctionType(VPSettingBaseFunctionSwitchType.automaticTemperatureTest, settingState: .readFunctionState, complete: { [weak self](state) in
                let open = state == VPSettingFunctionCompleteState.functionCompleteOpen
                self?.monitorSwitch.setOn(open, animated: true)
            })
        }
    }

    // Read automatic measurement data
    @IBAction func readAutoTestDataBtnClick(_ sender: UIButton) {
        // After the data is read, it is stored in the database, and the data is directly taken from the database
        // Note⚠️Do not read concurrently with hrv/blood oxygen/daily data, etc.
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSdkStartReadDeviceTemperatureData({ [weak self] (readDeviceBaseDataState, totalDay, currentReadDayNumber, readCurrentDayProgress) in
            switch readDeviceBaseDataState {
            case .start:
                break
            case .reading:
                break
            case .complete:
                self?.getDataFromDatabase()
                break
            case .invalid:
                // Device does not support
                break
            default:
                break
            }
        })
        // If you design your own database storage, use the following way to read
//        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_readDeviceAutoTestTemperatureData(withDayNumber: 0, maxPackage: 1, result: { (tempDataArray, totalPackage, currentReadPackage) in
//            guard  let tempDataArray = tempDataArray  else {
//                return
//            }
//            print(tempDataArray)
//        })
    }
    
    func getDataFromDatabase() -> Void {
        let tableID = VPBleCentralManage.sharedBleManager()?.peripheralModel.deviceAddress;
        let arr = VPDataBaseOperation.veepooSDKGetDeviceTemperatureData(withDate: "2021-06-08", andTableID: tableID)
        print(arr as Any)
        let arr1 = VPDataBaseOperation.veepooSDKGetDeviceTemperatureData(withDate: "2021-06-07", andTableID: tableID)
        print(arr1?.count as Any)
        let arr2 = VPDataBaseOperation.veepooSDKGetDeviceTemperatureData(withDate: "2021-06-06", andTableID: tableID)
        print(arr2?.count as Any)
    }
    
    // Manual temperature measurement
    @IBAction func manualTestDataBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_temperatureTestStart(sender.isSelected, result: { [weak self](state, enable, progress, tempValue) in
            if state == .unsupported {
                _ = AppDelegate.showHUD(message: "The device does not support this function", hudModel: MBProgressHUDModeText, showView: self!.view)
            }
            if state == .close {
                print("End measurement")
            }
            if state == .open {
                if enable {
                    print("schedule:\(progress), body temperature:\(Double(tempValue)/Double(10))°C")
                    if progress == 100 {
                        _ = AppDelegate.showHUD(message: "After the measurement, the body temperature is:\(Double(tempValue)/Double(10))°C", hudModel: MBProgressHUDModeText, showView: self!.view)
                        self!.manualTestDataBtn.isSelected = false
                    }
                }else{
                    print("Device is busy")
                }
            }
        })
    }
    
    @IBAction func monitorSwitchAction(_ sender: UISwitch) {
        if support {
            // Unit settings
//            VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDKSettingBaseFunctionType(VPSettingBaseFunctionSwitchType.temperatureUnit, settingState: sender.isOn ? .settingFunctionOpen : .settingFunctionClose, complete: nil)
            // Automatic temperature monitoring switch
            VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDKSettingBaseFunctionType(VPSettingBaseFunctionSwitchType.automaticTemperatureTest, settingState: sender.isOn ? .settingFunctionOpen : .settingFunctionClose, complete: { [weak self](state) in
                switch state {
                case .functionCompleteUnknown:
                    break
                case .functionCompleteOpen:
                    _ = AppDelegate.showHUD(message: "Feature is on", hudModel: MBProgressHUDModeText, showView: (self?.view)!)
                    break
                case .functionCompleteClose:
                    _ = AppDelegate.showHUD(message: "Feature is off", hudModel: MBProgressHUDModeText, showView: (self?.view)!)
                    break
                case .functionCompleteFailure:
                    break
                case .functionCompleteComplete:
                    break
                }
            })
        }else{
            _ = AppDelegate.showHUD(message: "The device does not support this function", hudModel: MBProgressHUDModeText, showView: self.view)
        }
    }
}

//
//  VPSettingDeviceGPSViewController.swift
//  VeepooBleSDKDemo
//
//  Created by veepoo-cd on 2021/3/11.
//  Copyright © 2021 veepoo. All rights reserved.
//

import UIKit

typealias SendGPSToDeviceTask = (_ ackState:NSInteger,_ GPSState:NSInteger,_ model:VPDeviceGPSModel) -> ()

class VPSettingDeviceGPSViewController: UIViewController {
    
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var timezoneField: UITextField!
    @IBOutlet weak var timestampField: UITextField!
    @IBOutlet weak var altitudeTextField: UITextField!
    
    @IBOutlet weak var AGPSButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    var deviceGPSModel: VPDeviceGPSModel!
    var KAABAGPSModel: VPDeviceKAABAGPSModel!
    
    @IBOutlet weak var timestampField2: UITextField!
    
    var sendGPSToDeviceTask: SendGPSToDeviceTask!
    var sendTimer: Timer!
    var ackState: NSInteger = 0
    
    @IBOutlet weak var AppSendGPSBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceGPSModel = VPDeviceGPSModel.init()
        KAABAGPSModel = VPDeviceKAABAGPSModel.init()
        // Do any additional setup after loading the view.
        timestampField.text = String(format: "%.0f", Date().toGlobalTime().timeIntervalSince1970)
        timestampField2.text = String(format: "%.0f", Date().timeIntervalSince1970)
    }

    @IBAction func sendCommandBtnClick(_ sender: UIButton) {
        if longitudeField!.text!.isEmpty ||
            latitudeField!.text!.isEmpty ||
            timezoneField!.text!.isEmpty ||
            timestampField!.text!.isEmpty ||
            altitudeTextField!.text!.isEmpty {
            _ = AppDelegate.showHUD(message: "Parameter cannot be empty", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        // Determine whether the time zone is a multiple of 15
        if (Int16(timezoneField.text!) ?? 0) % 15 != 0 {
            _ = AppDelegate.showHUD(message: "The time zone can only be a multiple of 15 minutes", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        // Add latitude and longitude range verification by yourself
        
        deviceGPSModel.longitude = Int32((Double(longitudeField.text!) ?? 0) * 100000)
        deviceGPSModel.latitude = Int32((Double(latitudeField.text!) ?? 0) * 100000)
        deviceGPSModel.timezone = Int16(timezoneField.text!) ?? 0
        deviceGPSModel.timestamp = Int(timestampField.text!) ?? 0
        deviceGPSModel.altitude = Int16(altitudeTextField.text!) ?? 0
        
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_setDeviceGPSAndTimezone(with: deviceGPSModel, result: { [weak self](state) in
            _ = AppDelegate.showHUD(message: state == 1 ? "Set up successfully" : "Failed to set up", hudModel: MBProgressHUDModeText, showView: (self?.view)!)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Recitation count read
    @IBAction func hadjCountReadBtn(_ sender: UIButton) {
//        let timeFormatter = DateFormatter()
//        //日期显示格式，可按自己需求显示
//        timeFormatter.dateFormat = "yyyy-MM-dd"
//        let strNowTime = timeFormatter.date(from: timeFormatter.string(from: Date()))
//        // 当天开始时间戳
//        let toDayTimestamp = Int(UInt64.init(strNowTime!.timeIntervalSince1970))
        // 当前时间戳
//        let currentTimestamp = Int(UInt64.init(Date().timeIntervalSince1970))
        let timestamp = Int(timestampField2.text!) ?? 0
        // timestamp Read the data after which timestamp, and return the data whose end timestamp is greater than the issued timestamp. The chanting channel records 31 days of data at most
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_readHadjCount(withTimestamp: timestamp, result: { [weak self](model) in
            let model = model! as VPDeviceHadjCountModel
            let str = "Current number of chants:\(model.currentCount) Start timestamp:\(model.startTimestamp) End timestamp:\(model.endTimestamp)"
            self?.printText(str)
            if model.totalCount == model.currentCount {
                self?.printText("Read the number of chants completed")
            }
        })
    }
    
    @IBAction func KAABAGPSSettingBtn(_ sender: UIButton) {
        KAABAGPSModel.longitude = Int32((Double(longitudeField.text!) ?? 0) * 100000)
        KAABAGPSModel.latitude = Int32((Double(latitudeField.text!) ?? 0) * 100000)
        KAABAGPSModel.altitude = Int16(altitudeTextField.text!) ?? 0
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_setKAABAGPS(with: KAABAGPSModel, result: { [weak self](state) in
            _ = AppDelegate.showHUD(message: state == 1 ? "Set up successfully" : "Failed to set up", hudModel: MBProgressHUDModeText, showView: (self?.view)!)
        })
    }
    
    
    /// The device actively requests the app to issue GPS data
    @IBAction func AppSendGPSToDeviceBtn(_ sender: UIButton) {
        _ = AppDelegate.showHUD(message: "Clicked", hudModel: MBProgressHUDModeText, showView: view)
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_sendGPSDataToDevice({ [weak self](state, callBack) in
            self?.SendGPSToDeviceControl(state, callBack: callBack!)
        })
    }
    
    private func SendGPSToDeviceControl(_ state: NSInteger, callBack: @escaping SendGPSToDeviceTask){
        // callback Assignment
        sendGPSToDeviceTask = callBack
        ackState = state
        if state == 0x01 {
            AppSendGPSBtn.isEnabled = false
            if sendTimer == nil {
                sendTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { [weak self](Timer) in
                    self?.SendTimerAction()
                })
            }
        }
        if state == 0x02 {
            AppSendGPSBtn.isEnabled = true
            // Destroy timer
            DestroySendTimer()
            // Send end ack and end package
            self.SendTimerAction()
            // Destroy Task closure (block)
            sendGPSToDeviceTask = nil
        }
    }
    
    // Timer loop operation
    @objc private func SendTimerAction(){
        if (sendGPSToDeviceTask != nil) {
            let gpsModel = VPDeviceGPSModel.init()
            // ... gpsModel assignment
            gpsModel.longitude = Int32((Double(longitudeField.text!) ?? 0) * 100000)
            gpsModel.latitude = Int32((Double(latitudeField.text!) ?? 0) * 100000)
            gpsModel.timezone = Int16(timezoneField.text!) ?? 0
            gpsModel.timestamp = Int(timestampField.text!) ?? 0
            // GPSState 0x01 means GPS signal is normal, 0x02 means signal is weak, 0x03 means permission is not enabled
            let GPSState: NSInteger = 0x01
            sendGPSToDeviceTask(ackState, GPSState, gpsModel)
        }
    }
    
    /// Destroy timer operation
    func DestroySendTimer() {
        guard let sendTimer1 = sendTimer else {
            return
        }
        sendTimer1.invalidate()
        sendTimer = nil
    }
    
    @IBAction func AGPSBtn(_ sender: UIButton) {
        let apgsFunction = VPBleCentralManage.sharedBleManager()?.peripheralModel.agpsFunction;
        print("Is there AGPS function: \(apgsFunction == 1 ? "Yes" : "No")")
        
//        let path = Bundle.main.path(forResource: "LTEPH_GPS_1", ofType: "rtcm")
//        let fileUrl = URL(fileURLWithPath: path!)
        
        AGPSButton.isEnabled = false
        
        var fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        fileUrl?.appendPathComponent("LTEPH_GPS_1-7.rtcm")
        
        let timestamp = Int(timestampField2.text!) ?? 0
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_AGPSTransform(withFileUrl: fileUrl, timestamp: timestamp, result: { [weak self](photoDialModel, marketDialModel, error) in
            self?.AGPSButton.isEnabled = true
            if error != nil {
                print(error! as NSError)
                self?.printText("\(error! as NSError)")
            }
        }, transformProgress: { [weak self](progress) in
            let proVlaue = Int(progress * 100)
            let proStr = "schedule: \(proVlaue) %"
            print(proStr)
            if(proVlaue % 2 == 0){
                self?.printText(proStr)
            }
        })
    }
    
    private func printText(_ str: String){
        self.textView.text.append(str)
        self.textView.insertText("\n\n")
        self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.count, 1))
    }
    
    // 设备主动上报GPS数据
    @IBAction func showGPS(_ sender: UIButton) {
        let vc = VPMapGPSTagViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension Date {

    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

}


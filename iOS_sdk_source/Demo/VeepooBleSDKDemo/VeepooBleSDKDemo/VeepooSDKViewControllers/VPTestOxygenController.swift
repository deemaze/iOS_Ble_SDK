//
//  VPTestOxygenController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/3/3.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPTestOxygenController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var averageOxygenValueLabel: UILabel!
    @IBOutlet weak var currentOxygenValueLabel: UILabel!
    @IBOutlet weak var currentRateValueLabel: UILabel!
    
    @IBOutlet weak var testOxygenBtn: UIButton!
    @IBOutlet weak var testRateBtn: UIButton!
    
    @IBOutlet weak var testOxygenTableView: UITableView!
    @IBOutlet weak var oxygenDateLabel: UILabel!
    
    // Respiration rate for one day array
    var oneDayOxygenArray: NSArray = []
    
    // Index to the current day
    var oxygenDayIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SpO2"
        getOneDayOxygenData()
    }
    
    func getOneDayOxygenData() {
        
        self.oxygenDateLabel.text = oxygenDayIndex.getOneDayDateString()
        let oxygenOneDayData = VPDataBaseOperation.veepooSDKGetDeviceOxygenData(withDate: self.oxygenDateLabel.text, andTableID: VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress)
        
        // Analyse the oxygen data obtained from the device
        let oxygenAnalysisArray = VPOxygenAnalysisModel(oneDayOxygens: oxygenOneDayData)
        
        self.averageOxygenValueLabel.text = "Average blood oxygen : " + (oxygenAnalysisArray?.aveOxygenValue.description ?? "0") + "%"
        
        // Return if no data for the date
        guard (oxygenAnalysisArray?.parseOneDayDict) != nil else {
            print("No respiration rate data for date \(self.oxygenDateLabel.text ?? oxygenDayIndex.getOneDayDateString())")
            oneDayOxygenArray = []
            testOxygenTableView.reloadData()
            return
        }
        
        // Get and convert to array the respiration rate for one day
        oneDayOxygenArray = (oxygenAnalysisArray?.parseOneDayDict["OxygenOneDayArray"]) as? NSArray ?? []

        // Reverse the values to display the time order by the most recent
        oneDayOxygenArray = oneDayOxygenArray.reversed() as NSArray

        testOxygenTableView.reloadData()
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

        // First judge whether it has this function
        if VPBleCentralManage.sharedBleManager().peripheralModel.oxygenType == 0 {
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
                case .testing: //The blood oxygen is being tested, and the blood oxygen value has been measured
                    weakSelf.currentOxygenValueLabel.text = "Current blood oxygen level: " + String(oxygenValue) + "%"
                case .notWear: //The wearing test failed, the test has ended
                    _ = AppDelegate.showHUD(message: "Wearing test failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .deviceBusy: //The device is busy and cannot be tested, the test has ended
                    _ = AppDelegate.showHUD(message: "Device side is operating", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .over: //The test ends normally and ends artificially
                    _ = AppDelegate.showHUD(message: "End of test", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .noFunction: //The device does not have this function
                    _ = AppDelegate.showHUD(message: "The device does not have this function", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .calibration: //Calibrating
                    weakSelf.currentOxygenValueLabel.text = "Calibration progress:" + String(oxygenValue) + "%"
                case .calibrationComplete: //Calibration is complete
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
    
    // Start testing the breathing rate
    @IBAction func startTestRateAction(_ sender: UIButton) {
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionDataTwo.copyBytes(to: &tbyte, count: tbyte.count)
        if tbyte[7] != 1 {// First judge whether it has this function
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
                case .testing: //Respiration rate being tested
                    weakSelf.currentRateValueLabel.text = "Test progress:" + String(testProgress) + "%"
                case .notWear: //The wearing test failed, the test has ended
                    weakSelf.currentOxygenValueLabel.text = "Wearing test failed"
                    sender.isSelected = false
                case .deviceBusy: //The device is busy and cannot be tested, the test has ended
                    weakSelf.currentRateValueLabel.text = "Device side is operating"
                    sender.isSelected = false
                case .over: //The test ends normally and ends artificially
                    weakSelf.currentRateValueLabel.text = "End of test"
                    sender.isSelected = false
                case .complete: //Completed normally
                    weakSelf.currentRateValueLabel.text = "Respiration rate:" + String(testValue) + "%" + "Times/min"
                    sender.isSelected = false
                case .failure: //Invalid test
                    weakSelf.currentRateValueLabel.text = "Invalid test"
                    sender.isSelected = false
                case .noFunction: //The device does not have this function
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
    
    //MARK: tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oneDayOxygenArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        }
        
        // Get the respiration rate values
        let oxygenRate = oneDayOxygenArray[indexPath.row] as? NSDictionary
        
        // Get the oxygen rate time
        let timeString = oxygenRate?["Time"] as! String
        
        // Get the next time in function of the timeString
        let nextTime = getNextTime(currentTime: timeString)
        
        cell?.textLabel?.text = timeString + "-" + nextTime
        cell?.detailTextLabel?.text = "Avg(\(oxygenRate?["OxygenAverageValue"] as? String ?? ""))"
        
        return cell!
    }
    
    private func getNextTime(currentTime: String) -> String {

        // Split the time string to get the hours and minutes
        let split = currentTime.components(separatedBy: ":")

        var hours = Int(split[0])!
        let minutes = Int(split[1])!

        // Add 10 minutes to get the next interval
        var nextMinutes = minutes + 10

        // In case of nextMinutes == 60, increment one hour and reset the minutes to 0
        if nextMinutes == 60 {
            hours += 1
            nextMinutes = 0

            return "0\(hours):0\(nextMinutes)"
        }
        return "0\(hours):\(nextMinutes)"
    }
    
    // Turn off the blood oxygen test when it is destroyed
    deinit {
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKTestOxygenStart(false, testResult: nil)
    }
}

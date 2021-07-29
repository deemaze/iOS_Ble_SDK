//
//  VPTestRespirationRateController.swift
//  VeepooBleSDKDemo
//
//  Created by Miguel Ferreira on 23/07/2021.
//  Copyright © 2021 veepoo. All rights reserved.
//

import UIKit

class VPTestRespirationRateController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var testRespirationTableView: UITableView!
    
    @IBOutlet weak var testRespirationCurrentDateLabel: UILabel!
    
    @IBOutlet weak var avgRespirationRateLabel: UILabel!
    @IBOutlet weak var minRespirationRateLabel: UILabel!
    @IBOutlet weak var maxRespirationRateLabel: UILabel!
    
    // Respiration rate for one day array
    var oneDayRespirationRateArray: NSArray = []
    var dayIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Respiration Rate"
        obtainOneDayRespirationData()
    }

    @IBAction func selectRespirationLastDateAction(_ sender: UIButton) {
        dayIndex = dayIndex - 1
        obtainOneDayRespirationData()
    }
    
    @IBAction func selectRespirationNextDateAction(_ sender: UIButton) {
        dayIndex = dayIndex + 1
        obtainOneDayRespirationData()
    }
    
    func obtainOneDayRespirationData() {
        
        // Get the date string based of dayIndex
        self.testRespirationCurrentDateLabel.text = dayIndex.getOneDayDateString()
        
        // Get device oxygen data for a day
        let oxygenOneDayData = VPDataBaseOperation.veepooSDKGetDeviceOxygenData(withDate: self.testRespirationCurrentDateLabel.text, andTableID: VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress)
        
        // Analyse the oxygen data obtained from the device
        let oxygenAnalysisArray = VPOxygenAnalysisModel(oneDayOxygens: oxygenOneDayData)
        
        // Update the labels with the obtained values from the model
        self.avgRespirationRateLabel.text = "Respiration rate avg : " + (oxygenAnalysisArray?.aveRespirationRate.description ?? "0")
        self.minRespirationRateLabel.text = "Respiration rate min : " + (oxygenAnalysisArray?.minRespirationRate.description ?? "0")
        self.maxRespirationRateLabel.text = "Respiration rate max : " + (oxygenAnalysisArray?.maxRespirationRate.description ?? "0")
        
        // Return if no data for the date
        guard (oxygenAnalysisArray?.parseOneDayDict) != nil else {
            print("No respiration rate data for date \(self.testRespirationCurrentDateLabel.text ?? dayIndex.getOneDayDateString())")
            return
        }
        
        // Get and convert to array the respiration rate for one day
        oneDayRespirationRateArray = (oxygenAnalysisArray?.parseOneDayDict["VPRespirationRateOneDayArrayKey"]) as? NSArray ?? []
        
        // Reverse the values to display the time order by the most recent
        oneDayRespirationRateArray = oneDayRespirationRateArray.reversed() as NSArray
                
        testRespirationTableView.reloadData()
    }
    
    //MARK: tableView的代理
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oneDayRespirationRateArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        }
        
        // Get the respiration rate values
        let respirationRate = oneDayRespirationRateArray[indexPath.row] as? NSDictionary
        
        // Get the respiration rate time
        let timeString = respirationRate?["Time"] as! String
        
        // Get the next time in function of the timeString
        let nextTime = getNextTime(currentTime: timeString)
        
        cell?.textLabel?.text = timeString + "-" + nextTime
        cell?.detailTextLabel?.text = "Avg(\(respirationRate?["VPRespirationRateAverageValueKey"] as? String ?? ""))"
        cell?.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
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
    
    // Turn off the breathing rate test when it is destroyed
    deinit {
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKTestBreathingRateStart(false, testResult: nil)
    }
}

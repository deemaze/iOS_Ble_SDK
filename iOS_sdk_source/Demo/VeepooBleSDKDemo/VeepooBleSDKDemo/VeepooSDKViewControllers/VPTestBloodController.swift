//
//  VPTestBloodController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/2/22.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPTestBloodController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var systolicLabel: UILabel!
    
    @IBOutlet weak var diastolicLabel: UILabel!
    
    @IBOutlet weak var testProgressLabel: UILabel!
    

    @IBOutlet weak var bloodDateLabel: UILabel!
    
    @IBOutlet weak var testBloodTableView: UITableView!
    
    var bloodArray:Array<[String: String]> = [[String: String]()]
    
    var bloodDayIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "blood pressure"
        // Do any additional setup after loading the view.
        obtainOneDayBloodData()
    }
    
    @IBAction func obtainLastDataAction(_ sender: UIButton) {
        bloodDayIndex = bloodDayIndex - 1
        obtainOneDayBloodData()
    }
    
    @IBAction func obtainNextDataAction(_ sender: UIButton) {
        bloodDayIndex = bloodDayIndex + 1
        obtainOneDayBloodData()
    }
    
    @IBAction func startTestBloodAction(_ sender: UIButton) {
        
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionData.copyBytes(to: &tbyte, count: tbyte.count)
        if tbyte[1] != 1 {//先判断一下是否有这个功能
            _ = AppDelegate.showHUD(message: "The bracelet has no blood pressure function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            systolicLabel.text = "High pressure:0"
            diastolicLabel.text = "Low pressure:0"
            testProgressLabel.text = "Test progess:0%"
        }
        
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKTestBloodStart(sender.isSelected, testMode: 0) { (testBloodState, progress, systolic, diastolic) in
            if sender.isSelected {
                weakSelf.testProgressLabel.text = "Test progress:" + String(progress) + "%"
                weakSelf.systolicLabel.text = "High pressure:" + String(systolic)
                weakSelf.diastolicLabel.text = "Low pressure:" + String(diastolic)
                switch testBloodState {
                case .testing://正在测试中
                    print("We are tested")
                case .deviceBusy:
                    _ = AppDelegate.showHUD(message: "The device is busy, end the test", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .testFail:
                    _ = AppDelegate.showHUD(message: "Test failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .testInterrupt:
                    _ = AppDelegate.showHUD(message: "Artificial end of the test", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .complete:
                    _ = AppDelegate.showHUD(message: "The test has been completed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                case .noFunction:
                    _ = AppDelegate.showHUD(message: "The device does not have this function temporarily", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
                    sender.isSelected = false
                }
            }
        }
    }
    
    /// 获取某一天的血压历史数据
    func obtainOneDayBloodData() {
        self.bloodDateLabel.text = bloodDayIndex.getOneDayDateString()
        let bloodDataBaseArray = VPDataBaseOperation.veepooSDKGetBloodData(withDate: self.bloodDateLabel.text, andTableID: VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress)
        
        guard let bloodDataArray = bloodDataBaseArray else {
            self.bloodArray = [[String: String]]()
            testBloodTableView.reloadData()
            return
        }
        
        self.bloodArray = bloodDataArray as! Array<[String : String]>
        
        testBloodTableView.reloadData()
    }
    
    //MARK: tableView的代理
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bloodArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        }
        
        let bloodDict = bloodArray[indexPath.row]
        
        
        cell?.textLabel?.text = bloodDict["Time"]
        
    
        cell?.detailTextLabel?.text =  bloodDict["systolic"]! + "/" + bloodDict["diastolic"]!
        
        return cell!
    }
    
    deinit {//销毁的时候关闭血压测试
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKTestBloodStart(false, testMode: 0, testResult: nil)
    }
}




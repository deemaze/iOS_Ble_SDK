//
//  VPSettingFemaleRelatedController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/6/13.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPSettingFemaleRelatedController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    let cellID = "FemaleCell"

    var femaleRelatedTableView: UITableView?
    
    var femaleModel = VPDeviceFemaleModel()
    
    var femaleTitleArray = Array<String>()
    var femaleDetailArray = Array<String>()
    
    var selectView:VPFemaleSelectView {
        let selectView = VPFemaleSelectView(frame: UIScreen.main.bounds)
        selectView.isHidden = true
        UIApplication.shared.keyWindow?.addSubview(selectView)
        unowned let weakSelf = self
        selectView.callBackBlock = {(value:Bool) -> Void in
            if value == true {
                weakSelf.femaleRelatedTableView?.reloadData()
            }
            selectView.isHidden = true
        }
        return selectView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "Feminine project settings"
        // Do any additional setup after loading the view.
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionData.copyBytes(to: &tbyte, count: tbyte.count)
        if tbyte[12] == 0 {//First judge whether there is this function, 1 is the App side only supports all languages, 2 is the App side only supports Chinese and English, this is a product design problem, there is no difference on the bracelet, the reason is that only Chinese and English are made on the bracelet
            _ = AppDelegate.showHUD(message: "The bracelet has no feminine function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        self.setFemaleRelateControllerUI()
        //At the beginning, you need to read the bracelet first. The display on the App is based on the bracelet, and there must be a model for reading. As long as there is a model, it cannot be nil.
        let femaleModel = VPDeviceFemaleModel()
        //Start reading
        unowned let weakSelf = self;
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingDeviceFemale(with: femaleModel, settingMode: 2, successResult: { (deviceFemaleModel) in
            guard let deviceFemaleModel = deviceFemaleModel else {
                return
            }
            weakSelf.femaleModel = deviceFemaleModel
            weakSelf.femaleRelatedTableView?.reloadData()
            _ = AppDelegate.showHUD(message: "Read successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }) {
            _ = AppDelegate.showHUD(message: "Read failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
    }

    func setFemaleRelateControllerUI() {
        femaleRelatedTableView = UITableView(frame: view.bounds , style: .plain)
        femaleRelatedTableView?.dataSource = self
        femaleRelatedTableView?.delegate = self
        
        let footView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 60))
        let footBtn = UIButton(type: .custom)
        footBtn.frame = CGRect(x: 15, y: 7, width: footView.frame.size.width - 30, height: footView.frame.size.height - 14)
        footBtn.addTarget(self, action: #selector(startSettingFemaleAction), for: .touchUpInside)
        footBtn.backgroundColor = UIColor.lightGray
        footBtn.setTitle("Set up", for: .normal)
        footBtn.setTitleColor(UIColor.brown, for: .normal)
        footView.addSubview(footBtn)
        femaleRelatedTableView?.tableFooterView = footView
        view.addSubview(femaleRelatedTableView!)
    }

    @objc func startSettingFemaleAction() {
        unowned let weakSelf = self;
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingDeviceFemale(with: femaleModel, settingMode: 1, successResult: { (deviceFemaleModel) in
            guard let deviceFemaleModel = deviceFemaleModel else {
                return
            }
            weakSelf.femaleModel = deviceFemaleModel
            _ = AppDelegate.showHUD(message: "Set successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }) {
            _ = AppDelegate.showHUD(message: "Setup failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
    }

    func obtainUIShowMessage() -> Int {
        if self.femaleModel.femaleState == VPDeviceFemaleState(rawValue:0) {//No menstrual period
            self.femaleTitleArray = ["Menstrual period selection"]
            self.femaleDetailArray = ["No"]
            return 1
        }else if self.femaleModel.femaleState == VPDeviceFemaleState(rawValue:1) || self.femaleModel.femaleState == VPDeviceFemaleState(rawValue:2) {//Menstrual period or pregnancy period
            self.femaleTitleArray = ["Menstrual period selection","Last menstrual period date","Menstrual cycle","Normal duration of menstrual period"]
            self.femaleDetailArray = [self.femaleModel.femaleState == VPDeviceFemaleState(rawValue:1) ? "menstruation" : "Preparation period",self.femaleModel.lastMenstrualDate ?? "",String(self.femaleModel.menstrualCircle),String(self.femaleModel.menstrualDays)]
            return 4
        }else if self.femaleModel.femaleState == VPDeviceFemaleState(rawValue:3) {//Expected date of delivery
            self.femaleTitleArray = ["Menstrual period selection","Expected date of delivery"]
            self.femaleDetailArray = ["Pre-production",self.femaleModel.expectedDateOfChildbirth ?? ""]
            return 2
        }else if self.femaleModel.femaleState == VPDeviceFemaleState(rawValue:4) {//Expected date of delivery
            self.femaleTitleArray = ["Menstrual period selection", "last menstrual period date", "menstrual cycle", "normal menstrual period lasting days", "baby birthday", "baby gender"]
            self.femaleDetailArray = ["Bao Ma",self.femaleModel.lastMenstrualDate ?? "",String(self.femaleModel.menstrualCircle),String(self.femaleModel.menstrualDays),self.femaleModel.babyBirthday ?? "",self.femaleModel.isGirl ? "Female" : "male"]
            return 6
        }
        self.femaleTitleArray = ["Menstrual period selection"]
        self.femaleDetailArray = ["No"]
        return 1
    }

    //MARK: tableView的代理方法
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.obtainUIShowMessage()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        
        cell?.textLabel?.text = self.femaleTitleArray[indexPath.row]
        
        cell?.detailTextLabel?.text = self.femaleDetailArray[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectView = VPFemaleSelectView(frame: UIScreen.main.bounds)
        selectView.selectViewTitle = self.femaleTitleArray[indexPath.row]
        selectView.femaleModel = femaleModel
        UIApplication.shared.keyWindow?.addSubview(selectView)
        unowned let weakSelf = self
        selectView.callBackBlock = {(value:Bool) -> Void in
            if value == true {
                weakSelf.femaleRelatedTableView?.reloadData()
            }
            selectView.removeFromSuperview()
        }
    }
    
    //MARK: 销毁控制器前执行
    deinit {
        VPBleCentralManage.sharedBleManager().veepooSDKStopScanDevice()
    }
}

//
//  VPDeviceCountDownController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/6/15.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPDeviceCountDownController: UIViewController {

    @IBOutlet weak var currentCountDownLabel: UILabel!

    @IBOutlet weak var countDownBtn: UIButton!

    @IBOutlet weak var showSwitch: UISwitch!

    @IBOutlet weak var permanentTimeBackView: UIView!

    @IBOutlet weak var permanentSelectTimeBtn: UIButton!
    
    @IBOutlet weak var permanentTimeDetailLabel: UILabel!
    
    var countDownModel: VPDeviceCountDownModel = VPDeviceCountDownModel()
    
    var selectView:VPCountDownSelectView {
        let selectView = VPCountDownSelectView(frame: UIScreen.main.bounds)
        selectView.isHidden = true
        UIApplication.shared.keyWindow?.addSubview(selectView)
        unowned let weakSelf = self
        selectView.callBackBlock = {(value:Bool) -> Void in
            if value == true {
                weakSelf.readOrSettingCountDownWithCountDownModel(countDownModel: weakSelf.countDownModel, settingMode: 1)
            }
            selectView.isHidden = true
        }
        return selectView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Countdown setting"
        view.backgroundColor = UIColor.white
        //For all judgments of whether or not, you can make a package yourself. Because of the different needs of the developers, we don’t have a good package effect.
        if VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionDataTwo == nil {
            _ = AppDelegate.showHUD(message: "The bracelet does not have a countdown function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionDataTwo.copyBytes(to: &tbyte, count: tbyte.count)
        if tbyte[1] != 1 {//First judge whether it has this function
            _ = AppDelegate.showHUD(message: "The bracelet does not have a countdown function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        self.readOrSettingCountDownWithCountDownModel(countDownModel: countDownModel, settingMode: 2)
    }
    
    @IBAction func beginCountDownAction(_ sender: UIButton) {//Start or cancel the ongoing countdown of the current device
        if sender.isSelected == true {//Cancel countdown Cancellation is supported in the SDK, but the device does not support this cancellation function for the time being. Ask the product manager to consider how to design it. This function is temporarily useless. The SDK is only added for later demand expansion.
            self.readOrSettingCountDownWithCountDownModel(countDownModel: countDownModel, settingMode: 0)
        }else {
            self.showSelectView(selectViewTitle: "Countdown time")
        }
    }

    @IBAction func permanentSwitchAction(_ sender: UISwitch) {//Resident interface show or hide
        if countDownModel.countDownState == 3 {
            _ = AppDelegate.showHUD(message: "The device counts down normally", hudModel: MBProgressHUDModeText, showView: self.view)
            return
        }
        if sender.isOn == false {
            countDownModel.settingOperation = 0
            self.readOrSettingCountDownWithCountDownModel(countDownModel: countDownModel, settingMode: 1)
        }else {
            self.showSelectView(selectViewTitle: "Resident countdown time")
        }
        
    }
    
    @IBAction func selectPermanentTimeAction(_ sender: UIButton) {//Select the duration of the permanent countdown
        if countDownModel.countDownState == 3 {
            _ = AppDelegate.showHUD(message: "The device counts down normally", hudModel: MBProgressHUDModeText, showView: self.view)
            return
        }
        self.showSelectView(selectViewTitle: "Resident countdown time")
    }

    func readOrSettingCountDownWithCountDownModel(countDownModel: VPDeviceCountDownModel, settingMode:UInt) {//设置、读取或者监听倒计时
        unowned let weakSelf = self;
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingDeviceCountDown(with: countDownModel, settingMode: settingMode, successResult: { (deviceCountDownModel) in
            var tip = "Read successfully"
            if settingMode == 0 {
                tip = "Cancel success"
            }else if settingMode == 1 {
                tip = "Set successfully"
            }
            if deviceCountDownModel?.countDownState == 4 {
                tip = "End of countdown"
            }
            if deviceCountDownModel?.countDownState != 3 {
                _ = AppDelegate.showHUD(message: tip, hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            }
            weakSelf.countDownModel = deviceCountDownModel!
            weakSelf.updateUIShow()
        }) {
            var tip = "Read failed"
            if settingMode == 0 {
                tip = "Cancel failed"
            }else if settingMode == 1 {
                tip = "Setup failed"
            }
            _ = AppDelegate.showHUD(message: tip, hudModel: MBProgressHUDModeText, showView: weakSelf.view)
        }
    }

    func updateUIShow() {//Change the interface display according to the model
        currentCountDownLabel.text = String(countDownModel.currentCountDownTime)
        countDownBtn.isSelected = countDownModel.countDownState == 3
        showSwitch.isOn = countDownModel.isShow
        
        permanentTimeBackView.isHidden = !showSwitch.isOn
        
        permanentTimeDetailLabel.text = String(countDownModel.repeatTime)
    }

    func showSelectView(selectViewTitle: String)  {
        let selectView = VPCountDownSelectView(frame: UIScreen.main.bounds)
        selectView.selectViewTitle = selectViewTitle
        selectView.countDownModel = countDownModel
        UIApplication.shared.keyWindow?.addSubview(selectView)
        unowned let weakSelf = self
        selectView.callBackBlock = {(value:Bool) -> Void in
            if value == true {
                weakSelf.readOrSettingCountDownWithCountDownModel(countDownModel: weakSelf.countDownModel, settingMode: 1)
            }
            selectView.removeFromSuperview()
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

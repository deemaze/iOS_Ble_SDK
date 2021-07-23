//
//  VPSOSViewController.swift
//  VeepooBleSDKDemo
//
//  Created by zhangchong on 2020/6/16.
//  Copyright © 2020 zc.All rights reserved.
//

import UIKit

class VPSOSViewController: UIViewController {

    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    let bleManager: VPBleCentralManage = VPBleCentralManage.sharedBleManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "SOS debugging"
        bleManager.peripheralManage.receiveSoldierFeedback = {[weak self] in
            self?.stateLabel.text = "Receive the SOS distress message sent by the device"
        }
    }
    
    @IBAction func sendCommand(_ sender: UIButton) {
        if bleManager.isConnected == false {
            _ = AppDelegate.showHUD(message: "Device not connected", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        bleManager.peripheralManage.veepooSDKSend {[weak self] (success) in
            self?.stateLabel.text = success ? "Send successfully" : "Failed to send"
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        if bleManager.isConnected == false {
            _ = AppDelegate.showHUD(message: "Device not connected", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        if messageTextField.text?.count == 0 {
            _ = AppDelegate.showHUD(message: "Please enter the sending information", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        bleManager.peripheralManage.veepooSDKSend(toSoldierSpecialTask: 0xFF, taskMessage: messageTextField.text) {[weak self] (success) in
            self?.stateLabel.text = success ? "Send successfully" : "Failed to send"
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

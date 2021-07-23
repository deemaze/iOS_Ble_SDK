//
//  VPModifyPasswordController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/3/2.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPModifyPasswordController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var currentPassword: UITextField!
    
    @IBOutlet weak var modifyPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func modifyDevicePassword(_ sender: UIButton) {
        if currentPassword.text != VPBleCentralManage.sharedBleManager().peripheralModel.devicePassword {
            _ = AppDelegate.showHUD(message: "The current password does not match", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        if modifyPassword.text?.count != 4 {//It’s rigorous to add whether it’s all numbers. Developers can write it by themselves.
            _ = AppDelegate.showHUD(message: "Password must be 4 digits", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().veepooSDKSynchronousPassword(with: .SettingPasswordType, password: modifyPassword.text) { (resultType) in
            switch resultType {
            case .resetSuccess:
                _ = AppDelegate.showHUD(message: "Set successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            default:
                _ = AppDelegate.showHUD(message: "Setup failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            }
        }
    }
}










//
//  VPDFUController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/2/23.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPDFUController: UIViewController {

    @IBOutlet weak var dfuProgressLabel: UILabel!
    
    @IBOutlet weak var currentVersionLabel: UILabel!
    
    @IBOutlet weak var updateVersionLabel: UILabel!
    
    @IBOutlet weak var updateDesTextView: UITextView!
    
    
    
    //要声明一个全局属性，固件升级过程中请不要操作手机
    let dufOperationManager: VPDFUOperation = VPDFUOperation.dfuOperationShare()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Firmware upgrade"
        // Do any additional setup after loading the view.
        currentVersionLabel.text = "current version: " + VPBleCentralManage.sharedBleManager().peripheralModel.deviceVersion
        
        if (VPBleCentralManage.sharedBleManager().peripheralModel.deviceNetVersion == nil) {
            updateVersionLabel.text = "Upgrade version: " + "No new version"
        }else {
            //下边是升级版本和升级新固件描述
            updateVersionLabel.text = "updated version: " + VPBleCentralManage.sharedBleManager().peripheralModel.deviceNetVersion
            updateDesTextView.text = VPBleCentralManage.sharedBleManager().peripheralModel.deviceNetVersionDes.replacingOccurrences(of: "$", with: "\n")
        }
    }

    @IBAction func startDFUAction(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        if (VPBleCentralManage.sharedBleManager().peripheralModel.deviceNetVersion == nil) {
            dfuProgressLabel.text = "No new firmware, no need to upgrade"
            return
        }
        
        dfuProgressLabel.text = "Ready to upgrade"
        sender.isSelected = true
        unowned let weakSelf = self
        dufOperationManager.veepooSDKStartDfu { (dfuProgress, deviceDFUState) in
            switch deviceDFUState {
            case .fileNotExist:
                sender.isSelected = false
                _ = AppDelegate.showHUD(message: "The upgrade file does not exist and cannot be upgraded", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            case .start:
                _ = AppDelegate.showHUD(message: "Start to upgrade", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            case .updating:
                weakSelf.dfuProgressLabel.text = "Upgrade progress: " + String(dfuProgress) + "%"
            case .success:
                sender.isSelected = false
                _ = AppDelegate.showHUD(message: "update successed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            case .failure:
                sender.isSelected = false
                _ = AppDelegate.showHUD(message: "upgrade unsuccessful", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            }
        }
    }
    
    @IBAction func localTest(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        dfuProgressLabel.text = "Ready to upgrade"
        sender.isSelected = true
        unowned let weakSelf = self
        let filePath = Bundle.main.path(forResource: "A63_00630022_8065_fw_encryptandsign.bin", ofType: nil)
        dufOperationManager.veepooSDKStartDfu(withFilePath: filePath) { (dfuProgress, deviceDFUState) in
            switch deviceDFUState {
            case .fileNotExist:
                sender.isSelected = false
                _ = AppDelegate.showHUD(message: "The upgrade file does not exist and cannot be upgraded", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            case .start:
                _ = AppDelegate.showHUD(message: "Start to upgrade", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            case .updating:
                weakSelf.dfuProgressLabel.text = "Upgrade progress: " + String(dfuProgress) + "%"
            case .success:
                sender.isSelected = false
                _ = AppDelegate.showHUD(message: "update successed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            case .failure:
                sender.isSelected = false
                _ = AppDelegate.showHUD(message: "upgrade unsuccessful", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

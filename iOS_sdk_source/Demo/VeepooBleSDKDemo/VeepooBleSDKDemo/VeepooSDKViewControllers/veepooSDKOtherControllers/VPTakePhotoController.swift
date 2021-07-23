//
//  VPTakePhotoController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/2/23.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPTakePhotoController: UIViewController {

    @IBOutlet weak var takePhotoTypeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "camera function"
        
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionData.copyBytes(to: &tbyte, count: tbyte.count)
        if tbyte[6] != 1 {//先判断一下是否有这个功能
            _ = AppDelegate.showHUD(message: "The bracelet has no camera function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Exit the camera mode after exiting the interface
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingCameraType(.exit, settingAndMonitorResult: nil)
        
    }
    
    @IBAction func takePhotoAction(_ sender: UIButton) {
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingCameraType(sender.tag == 1 ? .exit : .enter) { (cameraType) in
            switch cameraType {
            case .exit:
                weakSelf.takePhotoTypeLabel.text = "Current bracelet mode: Exit photo mode"
            case .enter://After receiving the camera entry command, the App can call the camera and enter the camera mode
                weakSelf.takePhotoTypeLabel.text = "Current bracelet mode: enter the camera mode, you can call the camera"
            case .photo://After receiving the camera command here, the camera called by the App can call the camera function to take a photo. After entering the camera mode, the handband will receive this callback after shaking it.
                _ = AppDelegate.showHUD(message: "After receiving the photo instruction, you can take a photo", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            }
        }
    }

}

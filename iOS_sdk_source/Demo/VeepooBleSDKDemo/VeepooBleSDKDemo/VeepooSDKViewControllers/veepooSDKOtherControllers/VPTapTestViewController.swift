//
//  VPTapTestViewController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 2018/11/10.
//  Copyright © 2018 zc.All rights reserved.
//

import UIKit

class VPTapTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Knock test"
        VPBleCentralManage.sharedBleManager()
            .peripheralManage.receiveTapDeviceAlarm = { type in
                _ = AppDelegate.showHUD(message: type == 1 ? "Click command received" : "Double click command received", hudModel: MBProgressHUDModeText, showView: UIApplication.shared.keyWindow!)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

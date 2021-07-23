//
//  VPSyncPersonalInformationController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/2/17.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPSyncPersonalInformationController: UIViewController {

    @IBOutlet weak var statureLabel: UILabel!
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var birthLabel: UILabel!
    
    @IBOutlet weak var sexLabel: UILabel!
    
    @IBOutlet weak var stepTargetLabel: UILabel!
    
    @IBOutlet weak var statureSlider: UISlider!
    
    @IBOutlet weak var weightSlider: UISlider!
    
    @IBOutlet weak var sexSegControl: UISegmentedControl!
    
    @IBOutlet weak var birthSlider: UISlider!
    
    @IBOutlet weak var stepTargetSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //同步个人信息，一般是在手环连接或者个人资料信息该表的时候同步，现在没有读取功能，只要设置成功就可以了，这个资料一般都是以App个人资料为准，所以只有设置，根据下边的设置自己可以参考
        // Synchronize personal information, usually when the bracelet is connected or when the personal data information table is synchronized, there is no reading function now, as long as the setting is successful, this information is generally based on the App personal data, so only settings are available. You can refer to the settings below
        title = "Sync personal data"
    }

    @IBAction func sliderAction(_ sender: UISlider) {
        let changeValue = UInt16(sender.value)
        switch sender.tag {
        case 0:
            statureLabel.text = "Height:" + String(changeValue)
        case 1:
            weightLabel.text = "Body weight:" + String(changeValue)
        case 2:
            birthLabel.text = "Born:" + String(changeValue)
        case 3:
            stepTargetLabel.text = "The goal:" + String(changeValue)
        default:
            print("error")
        }
    }

    
    @IBAction func sexSegControlAction(_ sender: UISegmentedControl) {
        sexLabel.text = sender.selectedSegmentIndex == 0 ? "Gender: Female" : "Sex: Male"
    }
    
    @IBAction func startSyncAction(_ sender: UIButton) {//开始同步个人数据
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSynchronousPersonalInformation(withStature: UInt(statureSlider.value), weight: UInt(weightSlider.value), birth: UInt(birthSlider.value), sex: UInt(sexSegControl.selectedSegmentIndex), targetStep: UInt(stepTargetSlider.value)) { (syncState) in
            if syncState == 1 {
                _ = AppDelegate.showHUD(message: "Set successfully", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            }else {
                _ = AppDelegate.showHUD(message: "Setup failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            }
        }
    }
}







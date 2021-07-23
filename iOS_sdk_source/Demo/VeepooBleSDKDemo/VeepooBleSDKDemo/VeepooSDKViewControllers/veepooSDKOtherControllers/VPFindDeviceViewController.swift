//
//  VPFindDeviceViewController.swift
//  VeepooBleSDKDemo
//
//  Created by veepoo-cd on 2021/3/8.
//  Copyright © 2021 veepoo. All rights reserved.
//

import UIKit

class VPFindDeviceViewController: UIViewController {
    @IBOutlet weak var supportLabel: UILabel!
    @IBOutlet weak var rssiValueLabel: UILabel!
    @IBOutlet weak var searchDeviceBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 1. Determine whether it supports the mobile phone search bracelet function
        let support = VPBleCentralManage.sharedBleManager()?.peripheralModel.searchDeviceFunction == 1
        print("Does it support: \(support)")
        supportLabel.text = support ? "Supported " : "Not supported"
        searchDeviceBtn.isEnabled = support
    }
    
    // 2. Semaphore monitoring of the connected device After opening the bracelet search, create a timer to read the semaphore of the device in a loop
    // Semaphore reference: [very good, good, medium, bad] can be graded by yourself
    // (-60,   ∞) The signal is very good
    // (-70, -60] Good signal
    // (-85, -70] Signal
    // (-∞ , -85] weak signal
    @IBAction func readConnectedDeviceRSSIValue(_ sender: UIButton) {
        VPBleCentralManage.sharedBleManager()?.veepooSDKReadConnectedPeripheralRSSIValue({ [weak self](rssiValue) in
            print("rssiValue: \(rssiValue)")
            self?.rssiValueLabel.text = "Current signal value:\(rssiValue)"
        })
    }
    
    // 3. Find the bracelet command protocol, if the device does not add the relevant protocol, there will be no return value
    @IBAction func startSearchDeviceClick(_ sender: UIButton) {
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_searchDeviceFuntion(withState: !sender.isSelected, result: { [weak self](start, state) in
            print("state: \(state.rawValue)")
            if state.rawValue == 2 || state.rawValue == 3 {//The device actively exits or search timeout
                self?.searchDeviceBtn.isSelected = false
            }
        })
        sender.isSelected = !sender.isSelected
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

//
//  VPPTTTestController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 2019/10/17.
//  Copyright © 2019 zc.All rights reserved.
//

import UIKit

class VPPTTTestController: UIViewController {
    @IBOutlet weak var pttStateLabel: UILabel!
    
    @IBOutlet weak var pttTestBtn: UIButton!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var signalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        //监听设备是否处于PTT模式下
        VPBleCentralManage.sharedBleManager()?
            .peripheralManage.veepooSDKAddPTTStateListener({[weak self] (state) in
            self?.pttStateLabel.text = state == 1 ? "The device has entered PTT mode" : "The device has not entered PTT mode"
        })
    }
    
    @IBAction func startPttDataCollection(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        VPBleCentralManage.sharedBleManager()?
            .peripheralManage.veepooSDKPTTTest(sender.isSelected, valueBlock: {[weak self] (valueModel) in
                self?.handleValue(valueModel)
            }, signal: {[weak self] (signals) in
                self?.handleSignals(signals)
            })
    }
    
    func handleValue(_ model: VPPttValueModel?) {
        switch model!.testState {
        case .normal:
            valueLabel.text = "Heart rate:\(model!.heart)    HRV:\(model!.hrv)    QT:\(model!.qt)"
        case .busy:
            valueLabel.text = "The device is processing other things"
        case .leadFail:
            valueLabel.text = "Device leads fall off"
        default:
            valueLabel.text = ""
        }
    }
    
    func handleSignals(_ signals: [NSNumber]?) {
        guard let deviceSignals = signals else {
            return;
        }
        signalLabel.text = ""
        for signal in deviceSignals {
            signalLabel.text = (signalLabel.text)! + "    " +  "\(signal)"
        }
    }
}

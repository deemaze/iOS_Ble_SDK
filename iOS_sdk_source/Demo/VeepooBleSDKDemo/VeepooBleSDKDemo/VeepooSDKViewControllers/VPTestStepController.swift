//
//  VPTestStepController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/2/23.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPTestStepController: UIViewController {

    @IBOutlet weak var stepDateLabel: UILabel!
    
    @IBOutlet weak var stepValueLabel: UILabel!
    @IBOutlet weak var disValueLabel: UILabel!
    @IBOutlet weak var calValueLabel: UILabel!
    
    var stepDayIndex = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        obtainOneDayStepData()
        title = "Step count"
        // Do any additional setup after loading the view.
    }

    @IBAction func testStepLastDayAction(_ sender: UIButton) {
        stepDayIndex = stepDayIndex - 1
        obtainOneDayStepData()
    }
    
    @IBAction func testStepNextDayAction(_ sender: UIButton) {
        stepDayIndex = stepDayIndex + 1
        obtainOneDayStepData()
    }
    
    func obtainOneDayStepData() {
        self.stepDateLabel.text = stepDayIndex.getOneDayDateString()
        
        //下边的175是一个人的身高单位cm，不同的身高对应不同的卡路里和距离
        unowned let weakSelf = self
        VPDataBaseOperation.veepooSDKGetStepData(withDate: self.stepDateLabel.text!, andTableID: VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress, changeUserStature: VPBleCentralManage.sharedBleManager().peripheralModel.deviceStature) { (stepDataBaseDict) in
            guard let stepDict:[String: String] = stepDataBaseDict as! [String : String]? else {
                weakSelf.stepValueLabel.text = "Step count: 0" + "step"
                weakSelf.disValueLabel.text = "Distance: 0" + "km"
                weakSelf.calValueLabel.text = "Calories: 0" + "Kcal"
                return
            }
            weakSelf.stepValueLabel.text = "Step count: " + stepDict["Step"]! + "step"
            weakSelf.disValueLabel.text = "Distance: " + stepDict["Dis"]! + "km"
            weakSelf.calValueLabel.text = "Calories: " + stepDict["Cal"]! + "Kcal"
        }
    }

}

//
//  VPNewAlarmCell.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/6/16.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPNewAlarmCell: UITableViewCell {
    
    var alarmModel:VPDeviceNewAlarmModel? {
        willSet {
            timeLabel.text = (newValue?.alarmHour)! + ":" + (newValue?.alarmMinute)!
            alarmSwitch.isOn = UInt((newValue?.alarmState)!) == 1
            
            if UInt((newValue?.repeatState)!) == 0 {//Single reminder
                alarmSwitch.isHidden = true
                repeatLabel.text = newValue?.alarmDate
            }else {
                alarmSwitch.isHidden = false
                repeatLabel.text = newValue?.getRepeatWeek()
            }
            if Int((newValue?.alarmScene)!)! == 0 {
                alarmImageView.image = UIImage(named: "clockP-select")
                return
            }
            //Optimize the code below. I mainly implement a way. The scene label on the bracelet and the App terminal are one-to-one correspondence. According to the cut pictures here, you can redesign the size and color by yourself.
            var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
            VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionData.copyBytes(to: &tbyte, count: tbyte.count)
            if (tbyte[17] == 1) {//Corresponding to different UI, now there are only two
                let imageName = String(format: "alarmLabelJ%d_select", Int((newValue?.alarmScene)!)!)
                alarmImageView.image = UIImage(named: imageName)
            }else if (tbyte[17] == 2) {
                let imageName = String(format: "alarmLabelP%d_select", Int((newValue?.alarmScene)!)!)
                alarmImageView.image = UIImage(named: imageName)
            }else {
                let imageName = String(format: "alarmLabelP%d_select", Int((newValue?.alarmScene)!)!)
                alarmImageView.image = UIImage(named: imageName)
            }
        }
    }

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var repeatLabel: UILabel!

    @IBOutlet weak var alarmSwitch: UISwitch!

    @IBOutlet weak var alarmImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

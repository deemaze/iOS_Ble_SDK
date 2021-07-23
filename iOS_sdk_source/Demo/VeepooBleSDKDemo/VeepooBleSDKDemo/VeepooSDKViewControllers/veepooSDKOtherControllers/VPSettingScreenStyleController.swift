//
//  VPSettingScreenStyleController.swift
//  VeepooBleSDKDemo
//
//  Created by 张冲 on 17/9/19.
//  Copyright © 2017年 zc.All rights reserved.
//

import UIKit

class VPSettingScreenStyleController: UIViewController ,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var screenTableView: UITableView!
    var styleCount = 0 //There are several screen style settings

    var screenStyle = 100 //The style of the screen, no default

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Color screen style setting"
        // Do any additional setup after loading the view.
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager().peripheralModel.deviceFuctionDataTwo.copyBytes(to: &tbyte, count: tbyte.count)
        styleCount = Int(tbyte[6])
        if styleCount == 0 {
            _ = AppDelegate.showHUD(message: "No screen style setting function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingDeviceScreenStyle(0, settingMode: 2) {[weak self] (screenStyle, settingSuccess) in
            if settingSuccess == true {
                self?.screenStyle = Int(screenStyle)
            }else {
                _ = AppDelegate.showHUD(message: "Read failed", hudModel: MBProgressHUDModeText, showView: (self?.view)!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return styleCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        if indexPath.row == 0 {
            cell.textLabel?.text = "Default style"
        }else {
            cell.textLabel?.text = "Screen style" + String(indexPath.row)
        }
        if indexPath.row == screenStyle {
            cell.detailTextLabel?.text = "✔︎"
            cell.detailTextLabel?.textColor = UIColor.cyan;
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        unowned let weakSelf = self
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSettingDeviceScreenStyle(Int32(indexPath.row), settingMode: 1) { (screenStyle, settingSuccess) in
            if settingSuccess == true {
                weakSelf.screenStyle = Int(screenStyle)
            }else {
                _ = AppDelegate.showHUD(message: "Setup failed", hudModel: MBProgressHUDModeText, showView: weakSelf.view)
            }
            tableView.reloadData()
        }
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

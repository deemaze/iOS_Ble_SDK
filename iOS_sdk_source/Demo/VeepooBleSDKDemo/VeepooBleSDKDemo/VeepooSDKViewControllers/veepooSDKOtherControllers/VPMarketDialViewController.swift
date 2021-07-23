//
//  VPMarketDialViewController.swift
//  VeepooBleSDKDemo
//
//  Created by veepoo-cd on 2021/1/27.
//  Copyright © 2021 veepoo. All rights reserved.
//

import UIKit

class VPMarketDialViewController: UIViewController {
    
    @IBOutlet weak var dialTypeLabel: UILabel!
    @IBOutlet weak var readDeviceScreenButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var supportMarketDialFunction = false
    
    var dialModel: VPDialModel!
    
    var deviceMarketDialModel: VPDeviceMarketDialModel!
    var marketDialArray: [VPServerMarketDialModel] = []
    
    var filePath: URL!
    
    var marketDialManager: VPMarketDialManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Market dial"
        
        // Photo dial flag
        supportMarketDialFunction = (VPBleCentralManage.sharedBleManager()?.peripheralModel.marketDialCount)! > 0
        if !supportMarketDialFunction {
            _ = AppDelegate.showHUD(message: "Does not support the market watch face function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        
        self.readDeviceScreenButton.sendActions(for: .touchUpInside)
//        dialModel = VPBleCentralManage.sharedBleManager()?.peripheralModel.dialModel
//
//        print(dialModel as VPDialModel)
        
        marketDialManager = VPMarketDialManager.share()
    }
    // MARK: - Device screen reading and switching
    
    // Read the watch face currently displayed by the device
    // settingMode: 1Stands for setting, 2 stands for read
    // dialType: 0 Default watch face 1 Market watch face 2 Photo watch face
    // screenStyle The market dial/photo dial starts from 1, the default dial starts from 0
    @IBAction func readDeviceScreenStyleClick(_ sender: UIButton) {
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDKSettingDeviceScreenStyle(0, settingMode: 2, dialType: .market, result: { [weak self](dialType, screenStyle, settingSuccess) in
//            print("读取>> screenStyle: \(screenStyle), settingSuccess:\(settingSuccess)")
            self?.dialTypeLabel.text = "\(dialType.rawValue) - \(screenStyle)"
        })
    }

    @IBAction func setDeviceScreenStyleToMarketClick(_ sender: UIButton) {
        let support = self.supportMarketDialFunction
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDKSettingDeviceScreenStyle(1, settingMode: 1, dialType: .market, result: { [weak self](dialType, screenStyle, settingSuccess) in
//            print("设置>> screenStyle: \(screenStyle), settingSuccess:\(settingSuccess)")
            if !settingSuccess && support {
                // The device supports the market watch face, but the watch face has not been transferred. First transfer the watch face in the market watch face
                _ = AppDelegate.showHUD(message: "The device supports the market watch face, but the watch face has not been transferred", hudModel: MBProgressHUDModeText, showView: (self?.view)!)
            }else{
                self?.readDeviceScreenButton.sendActions(for: .touchUpInside)
            }
        })
    }
    
    // MARK: - Market dial information reading, UI data transmission
    
    @IBAction func readDeviceMarketDialInfoClick(_ sender: UIButton) {
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_dialChannel(with: .read, dialType: .market, photoDialModel: nil, result: { [weak self](photoDialModel, deviceMarketDialModel, error) in
            if error == nil {
                self?.deviceMarketDialModel = deviceMarketDialModel!
            }
        }, transformProgress: nil)
    }
    
    // Get all the market watch face model objects of the server about this device. fileUrl is the UI file to be transferred to the device, and previewUrl is the preview image
    @IBAction func getServerMarketDialsClick(_ sender: UIButton) {
        if deviceMarketDialModel == nil {
            _ = AppDelegate.showHUD(message: "Please get the device market dial information first", hudModel: MBProgressHUDModeText, showView: view)
            return
        }

        marketDialManager.getVeepooServerAllMarketDials(withDeviceInfo: deviceMarketDialModel) { [weak self](marketDialArray) in
            guard  let marketDialArray = marketDialArray  else {
                return
            }
            self?.marketDialArray = marketDialArray
            if marketDialArray.count > 0 {
                var str = ""
                for item in marketDialArray {
                    str = str.appending("\(item.fileUrl) \n")
                }
                self?.textView.text = str
            }
        } failure: { (error, code) in
            
        }
    }
    
    // Download the UI transfer file in the selected model download file
    @IBAction func downloadTransferBinFileClick(_ sender: UIButton) {
        if marketDialArray.count == 0 {
            _ = AppDelegate.showHUD(message: "Please get the server market dial first", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        // Test the first one to verify the effect, please take marketDialArray.first.previewUrl to view the preview
        marketDialManager.downloadMarketDialBinFile(with: marketDialArray.first!, deviceMarketDialModel: deviceMarketDialModel) { [weak self](filePath) in
            self?.filePath = filePath!
            print("download successful!")
        } failure: { (error, code) in
            
        }
    }
    
    // Transfer the successfully downloaded bin file to the device
    @IBAction func transferMarketDialToDeviceClick(_ sender: UIButton) {
        if filePath == nil {
           _ = AppDelegate.showHUD(message: "Please download the watch face file first", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        marketDialManager.startTransfer(withFilePath: filePath) { (progress) in
            print("schedule: \(progress * 100) %")
        } failure: { (error) in
            if error != nil{
                print(error! as NSError)
            }
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

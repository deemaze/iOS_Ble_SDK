//
//  VPPhotoDialViewController.swift
//  VeepooBleSDKDemo
//
//  Created by veepoo-cd on 2021/1/21.
//  Copyright © 2021 veepoo. All rights reserved.
//

import UIKit

class VPPhotoDialViewController: UIViewController {
    
    @IBOutlet weak var dialTypeLabel: UILabel!
    @IBOutlet weak var readPhotoDialDetailButton: UIButton!
    @IBOutlet weak var readDeviceScreenButton: UIButton!
    var photoDialModel : VPPhotoDialModel!
    
    @IBOutlet weak var showPhotoDialViewButton: UIButton!
    var photoDialView : VPPhotoDialView!
    
    var supportPhotoDialFunction:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo dial"
        // Photo dial flag
        supportPhotoDialFunction = (VPBleCentralManage.sharedBleManager()?.peripheralModel.photoDialCount)! > 0
        if !supportPhotoDialFunction {
            _ = AppDelegate.showHUD(message: "Does not support photo watch face function", hudModel: MBProgressHUDModeText, showView: view)
            return
        }
        self.readDeviceScreenButton.sendActions(for: .touchUpInside)
        self.readPhotoDialDetailButton.sendActions(for: .touchUpInside)
    }
    // MARK: - Device screen reading and switching
    
    // Read the watch face currently displayed by the device
    // dialType: 0 Default watch face 1 Market watch face 2 Photo watch face
    // screenStyle The market dial/photo dial starts from 1, the default dial starts from 0
    @IBAction func readDeviceScreenStyleClick(_ sender: UIButton) {
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDKSettingDeviceScreenStyle(0, settingMode: 2, dialType: .photo, result: { [weak self](dialType, screenStyle, settingSuccess) in
            print("Read>> screenStyle: \(screenStyle), settingSuccess:\(settingSuccess)")
            self?.dialTypeLabel.text = "\(dialType.rawValue) - \(screenStyle)"
        })
    }
    
    // Set the device watch face to the photo watch face
    @IBAction func setScreenStyleToPhotoDial(_ sender: UIButton) {
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDKSettingDeviceScreenStyle(1, settingMode: 1, dialType: .photo, result: { [weak self](dialType, screenStyle, settingSuccess) in
            print("Set up>> screenStyle: \(screenStyle), settingSuccess:\(settingSuccess)")
            self?.readDeviceScreenButton.sendActions(for: .touchUpInside)
        })
    }
    
    // MARK: - Photo dial transmission, element setting, effect View display
    // Read the photo dial information and get the VPPhotoDialModel model
    // SDK users should hold the model by themselves, and the settings and display effects of the View are based on the model read.
    @IBAction func readPhotoDialDetailInfo(_ sender: UIButton) {
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_dialChannel(with: .read, dialType: .photo, photoDialModel: nil, result: { [weak self](photoDialModel, deviceMarketDialModel, error) in
            self?.photoDialModel = photoDialModel! as VPPhotoDialModel
        }, transformProgress: nil);
    }
    
    @IBAction func setPhotoDialToDefault(_ sender: UIButton) {
        if self.photoDialModel == nil {
            return
        }
//        self.photoDialModel.timePosition = .top
        self.photoDialModel.setColor = "00FF00"
        self.photoDialModel.isDefaultBG = true
        self.photoDialModel.transformImage = nil // transformImage must be empty
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_dialChannel(with: .setupPhotoDial, dialType: .photo, photoDialModel: self.photoDialModel, result: { (photoDialModel, deviceMarketDialModel, error) in
            if error != nil {
                print(photoDialModel! as VPPhotoDialModel)
            }
            print(error! as NSError)
        }, transformProgress: nil)
    }
    
    @IBAction func setPhotoDialDetailInfo(_ sender: UIButton) {
        if self.photoDialModel == nil {
            return
        }
//        self.photoDialModel.timePosition = .bottom
        self.photoDialModel.setColor = "FF0000"
        // The width and height of the transmitted picture must be consistent with the width and height of the screen. Please note that the resolution is the display resolution, namely 1x
        var image:UIImage!
        switch self.photoDialModel.screenType {
        // 240*240
        case .circle240_240,
             .square240_240,
             .circle240_240_QFN:
            image = UIImage.init(named: "test_240_240")
            break
        // 240*280
        case .square240_280,
             .square240_280_QFN:
            image = UIImage.init(named: "test_240_280")
            break
        // 240*295
        case .square240_295,
             .square240_295_QFN:
            image = UIImage.init(named: "test_240_295")
            break
        // 360*360
        case .circle360_360_QFN:
            image = UIImage.init(named: "test_360_360")
            break
        default:
            image = UIImage.init(named: "test_240_240")
            break
        }
        self.photoDialModel.transformImage = image
        VPBleCentralManage.sharedBleManager()?.peripheralManage.veepooSDK_dialChannel(with: .setupPhotoDial, dialType: .photo, photoDialModel: self.photoDialModel, result: { ( photoDialModel, deviceMarketDialModel, error) in
            print(error! as NSError)
        }, transformProgress: { (progress) in
            print("schedule：\(progress * 100) %")
        })
    }
    var timeIndex:UInt = 1
    var topAndBottomIndex:UInt = 0
    
    @IBAction func showPhotoDialViewButtonClick(_ sender: UIButton) {
        if photoDialView != nil {
            photoDialView.removeFromSuperview()
        }
        timeIndex += 1
        // Round screen test
        if timeIndex > 3 {
            timeIndex = 1 // Round screen starting from 1
        }
        
        // Square screen test
//        if timeIndex > 7 || timeIndex < 4 {
//            timeIndex = 4 // Square screen starts from 4
//        }
        
        // Elemental Training
        topAndBottomIndex += 1
        if topAndBottomIndex > 8 {
            topAndBottomIndex = 0
        }
        if self.photoDialModel.screenType == .square240_280_QFN && topAndBottomIndex == 8 {
            topAndBottomIndex = 0
        }
        
        self.photoDialModel.timePosition = VPPhotoDialTimePosition(rawValue: timeIndex)!

        self.photoDialModel.timeTopPosition = VPPhotoDialTimeTopAndBottomElement(rawValue: topAndBottomIndex)!

        self.photoDialModel.timeBottomPosition = VPPhotoDialTimeTopAndBottomElement(rawValue: topAndBottomIndex)!
        
        photoDialView = VPPhotoDialView.init(photoDialModel: self.photoDialModel)
        photoDialView.zc_x = 20
        photoDialView.zc_y = showPhotoDialViewButton.zc_bottom + 40
        
//        photoDialView.setBgImage(UIImage.init(named: "test_240_240")!)
//        photoDialView.setBgImage(UIImage.init(named: "test_240_280")!)
        photoDialView.showDefaultBgImage()
        
        view.addSubview(photoDialView)
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

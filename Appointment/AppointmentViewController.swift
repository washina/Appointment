//
//  AppointmentViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/04/25.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AppointmentViewController: UIViewController {
    
    // アウトレット接続
    @IBOutlet weak var toMailAddressTextField: UITextField!
    
    // rgb変換メソッド
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        /* SlideMenuControllerSwift設定 ----------------------------------------------------------------------*/
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barTintColor = UIColorFromRGB(rgbValue: 0x40e0d0)
//        navigationController?.navigationBar.tintColor = UIColorFromRGB(rgbValue: 0xffffff)
//        addRightBarButtonWithImage(UIImage(named: "menuIcon")!)
//        /* SlideViewControllerSwift設定 end-------------------------------------------------------------------*/

        // 背景色変更
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xeeeeee)
    }
    
    // 完了ボタンが押されたときにキーボードを隠す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func searchButton(_ sender: Any) {
        // 相手のメールアドレスから子要素があるか否かで条件分岐
        let toAddress = toMailAddressTextField.text!.replacingOccurrences(of: ".", with: ",")
        FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(toAddress){
                print("DEBUG_PRINT: メールアドレス認証成功")
                // 認証成功時にMapViewControllerにメールアドレスの情報を送り画面遷移
                let controller = self.presentingViewController as? MapViewController
                controller?.getAddress = toAddress
                self.dismiss(animated: true, completion: {
                    print("test")
                    controller?.appointmentSearch()
                })
            } else {
                SVProgressHUD.showError(withStatus: "メールアドレスが間違っています。")
                return
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

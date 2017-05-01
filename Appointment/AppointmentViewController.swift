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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // 完了ボタンが押されたときにキーボードを隠す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func searchButton(_ sender: Any) {
        // 相手のuidから子要素があるか条件分岐
        let toAddress = toMailAddressTextField.text!.replacingOccurrences(of: ".", with: ",")
        FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(toAddress){
                print("DEBUG_PRINT: メールアドレス認証成功")
                // 認証成功時にMapViewControllerにメールアドレスの情報を送り画面遷移
                let controller = self.presentingViewController as? MapViewController
                controller?.getAddress = toAddress
                self.dismiss(animated: true, completion: {
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

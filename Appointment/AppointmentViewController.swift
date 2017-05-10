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
    
    @IBOutlet weak var toMailAddressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // キーボードを閉じる
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 完了ボタンが押されたときにキーボードを隠す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let mapViewController:MapViewController = segue.destination as! MapViewController
        let toAddress = toMailAddressTextField.text!.replacingOccurrences(of: ".", with: ",")
        mapViewController.getAddress = toAddress
        FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(toAddress){
                print("DEBUG_PRINT: メールアドレス認証成功")
                // 認証成功時にMapViewControllerにメールアドレスの情報を送り画面遷移
                SVProgressHUD.showSuccess(withStatus: "メールアドレスを確認しました。")
                mapViewController.appointmentSearch()
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

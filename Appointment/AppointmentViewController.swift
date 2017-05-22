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
    @IBOutlet weak var searchButton: UIButton!
    
    var toAddress: String = ""
    
    // locationの値を取得
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // ボタンのデザイン変更
        self.searchButton.backgroundColor = UIColorFromRGB(rgbValue: 0xfa8072)
        self.searchButton.setTitleColor(UIColorFromRGB(rgbValue: 0xffffff), for: .normal)

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
    
    @IBAction func searchButton(_ sender: Any) {
        toAddress = toMailAddressTextField.text!.replacingOccurrences(of: ".", with: ",")
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.toAddress){
                SVProgressHUD.showSuccess(withStatus: "メールアドレスを確認しました。経路を表示します。")
                // appointmentBackで画面遷移
                self.performSegue(withIdentifier: "appointmentBack", sender: nil)
            } else {
                SVProgressHUD.showError(withStatus: "メールアドレスが間違っています。")
                return
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // 入力されたアドレスをdelegateLocationに渡す
        appDelegate.delegateLocation = (
            delegateAddress: "\(toAddress)",
            delegateLatitude: appDelegate.delegateLocation.delegateLatitude,
            delegateLongitude: appDelegate.delegateLocation.delegateLongitude
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

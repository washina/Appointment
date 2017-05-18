//
//  AddFavoriteViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/05/10.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AddFavoriteViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
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
    
    @IBAction func addRequest(_ sender: Any) {
        if mailAddressTextField.text != "" && userNameTextField.text != "" {
            // 登録者のメールアドレスを取得
            var hostMailAddress = FIRAuth.auth()?.currentUser?.email
            hostMailAddress = hostMailAddress?.replacingOccurrences(of: ".", with: ",")
            FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(hostMailAddress!){
                    // databaseからユーザを探し出し、favoriteに要素を入れる
                    let postRef = FIRDatabase.database().reference().child("users").child(hostMailAddress!).child("favorite")
                    let postData = ([
                        "userName": self.userNameTextField.text!,
                        "userMailAddress": self.mailAddressTextField.text!
                        ])
                    postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        postRef.child("\(snapshot.childrenCount)").updateChildValues(postData)
                    })
                    SVProgressHUD.showSuccess(withStatus: "お気に入りリストに追加されました。")
                } else {
                    SVProgressHUD.showError(withStatus: "メールアドレスが間違っています。")
                    return
                }
            })
        } else {
            // どちらか一方でも空
            SVProgressHUD.showError(withStatus: "必要項目を入力して下さい。")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

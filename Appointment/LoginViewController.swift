//
//  LoginViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/04/25.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    // 各TextFieldのアウトレット接続
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    //let uuid = NSUUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* ログイン処理 ------------------------------------------------------------------------------------*/
    @IBAction func loginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            // アドレスとパスワード名のいずれかでも入力されていないときは何もしない
            if address.characters.isEmpty || password.characters.isEmpty{
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            FIRAuth.auth()?.signIn(withEmail: address, password: password) { user, error in
                if let error = error {
                    print("DEBUG_PRINT:" + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました")
                    return
                } else {
                    print("DEBUG_PRINT: ログインに成功しました。")
                    
                    // HUDを消す
                    SVProgressHUD.dismiss()
                    
                    // 画面を閉じてViewControllerに戻る
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    /* ログイン処理 end---------------------------------------------------------------------------------*/

    /* アカウント作成処理 -------------------------------------------------------------------------------*/
    @IBAction func createAccountButton(_ sender: UIButton) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {
            
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.characters.isEmpty || password.characters.isEmpty || displayName.characters.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            FIRAuth.auth()?.createUser(withEmail: address, password: password) { user, error in
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました")
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                // 表示名を設定する
                let user = FIRAuth.auth()?.currentUser
                if let user = user {
                    let changeRequest = user.profileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            SVProgressHUD.showError(withStatus: "ユーザー作成時にエラーが発生しました")
                            print("DEBUG_PRINT: " + error.localizedDescription)
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName)]の設定に成功しました。")
                        
                        // 画面を閉じてViewControllerに戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    print("DEBUG_PRINT: displayNameの設定に失敗しました。")
                }

            }
        }
    }
    /* アカウント作成処理 end----------------------------------------------------------------------------*/

}

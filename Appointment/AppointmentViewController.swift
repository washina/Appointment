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
import UserNotifications

class AppointmentViewController: UIViewController {
    
    @IBOutlet weak var toMailAddressTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var postData: PostData!
    
    var toAddress: String = ""
    
    // request履歴を確認するための変数
    var haveAddressCheck = false
    var successCheck = false
    
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
        self.toAddress = self.toMailAddressTextField.text!.replacingOccurrences(of: ".", with: ",")
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.toAddress){
                
                let ref = Database.database().reference().child("users").child(self.toAddress)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    // Database上にrequestがあるかどうか
                    if snapshot.hasChild("request") {
                        print("DEBUG_PRINT: HAS_REQUEST")
                        
                        // Database上のrequestに自分のアドレスがあるかどうか（過去にリクエストを飛ばしたことがあるかどうか）
                        var userAddress = Auth.auth().currentUser?.email
                        userAddress = userAddress?.replacingOccurrences(of: ".", with: ",")
                        ref.child("request").observeSingleEvent(of: .value, with: { (snapshot) in
                            for count in 0 ..< snapshot.childrenCount {
                                ref.child("request").child("\(count)").observeSingleEvent(of: .value, with: { (snapshot) in
                                    let addressCheck: String = snapshot.childSnapshot(forPath: "userAddress").value! as! String
                                    
                                    if addressCheck == "\(userAddress!)" {
                                        print("DEBUG_PRINT: HAS_USERADDRESS")
                                        // requestしたことがある -> true
                                        self.haveAddressCheck = true
                                        
                                        let requestCheck: String = snapshot.childSnapshot(forPath: "requestCheck").value! as! String
                                        if requestCheck == "ok" {
                                            print("DEBUG_PRINT: REQUEST_OK")
                                            // 承認済み -> true
                                            self.successCheck = true
                                            
                                            SVProgressHUD.showSuccess(withStatus: "すでに承認済みです。経路を表示します。")
                                            self.prepareToData()
                                        }
                                    }
                                })
                                if count == snapshot.childrenCount {
                                    // 全てのデータを見終わったら処理を実行
                                    if self.successCheck == false {
                                        // HTTPリクエスト処理
                                        self.httpRequest()
                                    }
                                }
                            }
                        })
                        
                    } else {
                        print("DEBUG_PRINT: DONT_HAVE_REQUEST")
                        
                        // HTTPリクエスト処理
                        self.httpRequest()
                    }
                })
            } else {
                SVProgressHUD.showError(withStatus: "メールアドレスが間違っています。")
                return
            }
        })
    }
    
    /* httpRequest（通知処理） -----------------------------------------------------------------------------------------*/
    func httpRequest() {
        let ref = Database.database().reference().child("users").child(self.toAddress)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // request履歴がなければpostRequestを実行
            if self.haveAddressCheck == false {
                self.postRequest()
            }
            
            // 各情報をセット
            let uid = Auth.auth().currentUser?.uid
            let userAddress = Auth.auth().currentUser?.email
            self.postData = PostData(snapshot: snapshot, myId: uid!)
            let token = self.postData.token
            
            // HTTPリクエスト
            var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // サーバキーをセット
            request.setValue("key=AAAAsnK-W2A:APA91bFm-sAT9qzl_de-Z8yuMbisrorxQscnw1xS09ORlPlrE_I_suH0w8kDMNVs_wyg5O-bOAeDuGGMc8CvGhzqepXWiuN2sXwV2HLLnC0b-gutxFCVpLNsIoRMhPoTFshZ7aG9yMyA", forHTTPHeaderField: "Authorization")
            // 渡すデータをJSON形式で作成
            let json = [
                "to" : token!,
                "priority" : "high",
                "notification" : [
                    "body" : "\(userAddress!) さんから、リクエストが届いています。",
                    "Sound" : "default"
                ]
            ] as [String : Any]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                request.httpBody = jsonData
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error=\(error!)")
                        return
                    }
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        print("Status Code should be 200, but is \(httpStatus.statusCode)")
                        print("Response = \(response!)")
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(responseString!)")
                }
                task.resume()
            }
            catch {
                print(error)
            }
        })
        
        // appointmentBackで画面遷移
        SVProgressHUD.showSuccess(withStatus: "メールアドレスを確認、リクエストを送信しました。")
        self.prepareToData()
    }
    /* httpRequest（通知処理） end--------------------------------------------------------------------------------------*/

    
    /* postRequest ---------------------------------------------------------------------------------------------------*/
    func postRequest() {
        var userAddress = Auth.auth().currentUser?.email
        userAddress = userAddress?.replacingOccurrences(of: ".", with: ",")
        let postRef = Database.database().reference().child("users").child(self.toAddress).child("request")
        
        let setPostData = ([
            "userAddress": "\(userAddress!)",
            "requestCheck": "no"
        ])
        postRef.observeSingleEvent(of: .value, with: { (snapshot) in
            postRef.child("\(snapshot.childrenCount)").updateChildValues(setPostData)
        })
    }
    /* postRequest end------------------------------------------------------------------------------------------------*/

    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
//        // 入力されたアドレスをdelegateLocationに渡す
//        if self.successCheck == true {
//            appDelegate.delegateLocation = (
//                delegateAddress: "\(toAddress)",
//                delegateLatitude: appDelegate.delegateLocation.delegateLatitude,
//                delegateLongitude: appDelegate.delegateLocation.delegateLongitude
//            )
//        }
//    }
    
    func prepareToData() {
        if self.successCheck == true {
            appDelegate.delegateLocation = (
                delegateAddress: "\(toAddress)",
                delegateLatitude: appDelegate.delegateLocation.delegateLatitude,
                delegateLongitude: appDelegate.delegateLocation.delegateLongitude
            )
        }
        self.performSegue(withIdentifier: "appointmentBack", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

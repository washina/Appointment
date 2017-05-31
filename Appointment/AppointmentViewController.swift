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
                
                /* request確認処理 --------------------------------------------------------------------------------*/
                let ref = Database.database().reference().child("users").child(self.toAddress)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    // Database上にrequestがあるかどうか
                    if snapshot.hasChild("request") {
                        print("HAS_REQUEST")
                        
                        // Database上のrequestに自分のアドレスがあるかどうか（過去にリクエストを飛ばしたことがあるかどうか）
                        var userAddress = Auth.auth().currentUser?.email
                        userAddress = userAddress?.replacingOccurrences(of: ".", with: ",")
                        ref.child("request").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if snapshot.hasChild(userAddress!) {
                                print("HAS_USERADDRESS")   // 過去に飛ばしたことアリ
                                
                                let requestCheck: String = snapshot.childSnapshot(forPath: userAddress!).value! as! String
                                if requestCheck == "ok" {
                                    print("REQUEST_OK")   // 位置情報共有許可済み
                                    
                                    // performSegueでMapViewControllerへ戻り経路表示
                                    SVProgressHUD.showError(withStatus: "すでに承認済みです。経路を表示します。")
                                    self.performSegue(withIdentifier: "appointmentBack", sender: nil)
                                    
                                } else {
                                    print("REQUEST_NO")   // 位置情報共有許可ナシ
                                    
                                    // HTTPリクエスト処理
                                    self.httpRequest()
                                }
                            } else {
                                print("DONT_HAVE_USERADDRESS")    // 初めてリクエストを飛ばす
                                
                                // userAddress POST
                                self.postRequest()
                                
                                // HTTPリクエスト処理
                                self.httpRequest()
                            }
                        })
                        
                    } else {
                        print("DONT_HAVE_REQUEST")    // AppointmentViewControllerを初利用
                        
                        // userAddress POST
                        self.postRequest()
                        
                        // HTTPリクエスト処理
                        self.httpRequest()
                    }
                })
                /* request確認処理 end-----------------------------------------------------------------------------*/
                
                // appointmentBackで画面遷移
                SVProgressHUD.showSuccess(withStatus: "メールアドレスを確認、リクエストを送信しました。")
                self.performSegue(withIdentifier: "appointmentBack", sender: nil)
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
    }
    /* httpRequest（通知処理） end--------------------------------------------------------------------------------------*/

    
    /* postRequest ---------------------------------------------------------------------------------------------------*/
    func postRequest() {
        var userAddress = Auth.auth().currentUser?.email
        userAddress = userAddress?.replacingOccurrences(of: ".", with: ",")
        let postRef = Database.database().reference().child("users").child(self.toAddress).child("request")
        let setPostData = [
            "\(userAddress!)": "no"
        ] as [String: Any]
        postRef.updateChildValues(setPostData)
    }
    /* postRequest end------------------------------------------------------------------------------------------------*/

    
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

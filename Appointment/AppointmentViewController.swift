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
                SVProgressHUD.showSuccess(withStatus: "メールアドレスを確認しました。リクエストを送りました。")
                
                /* 通知送信処理 --------------------------------------------------------------------------------*/
                
                // FCMトークンを
                let token = InstanceID.instanceID().token()
                if token != nil {
                    var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("key=AAAAsnK-W2A:APA91bFm-sAT9qzl_de-Z8yuMbisrorxQscnw1xS09ORlPlrE_I_suH0w8kDMNVs_wyg5O-bOAeDuGGMc8CvGhzqepXWiuN2sXwV2HLLnC0b-gutxFCVpLNsIoRMhPoTFshZ7aG9yMyA", forHTTPHeaderField: "Authorization")
                    let json = [
                        "to" : "en4nf2wnE98:APA91bH9SG5Gfz-4Y9qw_G67XqWNtVueMPWfdTp47jUGkKFVN2dB1oTG84f3w6d47SPDUnFXI-KqAn1MGpfJ285r4CAQ2nJb-Bd6PBBzTHzDc2yfVOHp6YiMuoxtEZcyp4lJcoY0DGZO",
                        "priority" : "high",
                        "notification" : [
                            "body" : "PushTest",
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
                                // check for http errors
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
                }
                
                /* 通知送信処理 end-----------------------------------------------------------------------------*/
                
                // appointmentBackで画面遷移
                //self.performSegue(withIdentifier: "appointmentBack", sender: nil)
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

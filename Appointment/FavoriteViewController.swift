//
//  FavoriteViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/05/02.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import UserNotifications

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var addFavoriteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var postData: PostData!
    var observing = false
    
//    var selectedData: String = ""
    
    // request履歴を確認するための変数
    var toAddress: String = ""
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
        
        // ボタンの背景色設定
        self.addFavoriteButton.backgroundColor = UIColorFromRGB(rgbValue: 0x40e0de)
        
        // セルの高さ設定
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                // チェック用アドレス
                var address = Auth.auth().currentUser?.email
                address = address!.replacingOccurrences(of: ".", with: ",")
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef: DatabaseReference = Database.database().reference().child("users")
                postsRef.observe(.childAdded, with: { (snapshot) in
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        if(snapshot.key == address) {
                            self.postData = PostData(snapshot: snapshot, myId: uid)
                            // TableViewを再表示する
                            self.tableView.reloadData()
                        }
                    }
                })
                observing = true
            }
        } else {
            if observing == true {
                // テーブルをクリアする
                tableView.reloadData()
                // オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                observing = false
            }
        }
    }
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData == nil ? 0 : postData.favorite.count
    }

    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! FavoriteTableViewCell
        cell.setPostData(favorite: postData.favorite[indexPath.row])
        
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        self.toAddress = postData.favorite[indexPath.row]["userMailAddress"]!
        self.toAddress = self.toAddress.replacingOccurrences(of: ".", with: ",")
        let ref = Database.database().reference().child("users").child(self.toAddress)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Database上にrequestがあるかどうか
            if snapshot.hasChild("request") {
                print("DEBUG_PRINT: HAS_REQUEST")
                
                // Database上のrequestに自分のアドレスがあるかどうか（過去にリクエストを飛ばしたことがあるかどうか）
                var userAddress = Auth.auth().currentUser?.email
                userAddress = userAddress?.replacingOccurrences(of: ".", with: ",")
                ref.child("request").observeSingleEvent(of: .value, with: { (snapshot) in
                    let maxCount = snapshot.childrenCount
                    for count in 0 ..< maxCount {
                        ref.child("request").child("\(count)").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            // 判別に使用する文字列
                            let addressCheck = snapshot.childSnapshot(forPath: "userAddress").value! as! String
                            let requestCheck = snapshot.childSnapshot(forPath: "requestCheck").value! as! String
                            
                            if addressCheck == "\(userAddress!)" {
                                print("DEBUG_PRINT: HAS_USERADDRESS")
                                // requestしたことがある -> true
                                self.haveAddressCheck = true
                                
                                if requestCheck == "ok" {
                                    print("DEBUG_PRINT: REQUEST_OK")
                                    // 承認済み -> true
                                    self.successCheck = true
                                    
                                    SVProgressHUD.showSuccess(withStatus: "すでに承認済みです。経路を表示します。")
                                    self.prepareToData()
                                }
                            }
                        })
                        if count == (maxCount - 1) {
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
//        selectedData = postData.favorite[indexPath.row]["userMailAddress"]!
//        selectedData = selectedData.replacingOccurrences(of: ".", with: ",")
//        // favoriteBackで画面遷移
//        performSegue(withIdentifier: "favoriteBack", sender: nil)
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
    
    /* prepareToData -------------------------------------------------------------------------------------------------*/
    func prepareToData() {
        if self.successCheck == true {
            appDelegate.delegateLocation = (
                delegateAddress: "\(toAddress)",
                delegateLatitude: appDelegate.delegateLocation.delegateLatitude,
                delegateLongitude: appDelegate.delegateLocation.delegateLongitude
            )
        }
        self.performSegue(withIdentifier: "favoriteBack", sender: nil)
    }
    /* prepareToData end----------------------------------------------------------------------------------------------*/
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "favoriteBack") {
//            // タップされたセルのお気に入りデータをdelegateLocationに渡す
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.delegateLocation = (
//                delegateAddress: "\(selectedData)",
//                delegateLatitude: appDelegate.delegateLocation.delegateLatitude,
//                delegateLongitude: appDelegate.delegateLocation.delegateLongitude
//            )
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

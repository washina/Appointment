//
//  RequestViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/05/30.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RequestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backMapButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var postData: PostData!
    var observing = false
    
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
        self.backMapButton.backgroundColor = UIColorFromRGB(rgbValue: 0x40e0de)
        
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
    
    @IBAction func backMapButton(_ sender: Any) {
        performSegue(withIdentifier: "requestBack", sender: nil)
    }
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return postData == nil ? 0 : postData.request.count
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! RequestTableViewCell
        cell.setPostData(request: postData.request[indexPath.row])
        
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        
        // message作成
        let userAddress = postData.request[indexPath.row]["userAddress"]!
        let replacingUserAddress = userAddress.replacingOccurrences(of: ",", with: ".")
        let alertMessage = "ユーザー「\(replacingUserAddress)」に対する、\n位置情報共有の許可を変更しますか？"
        
        // alert作成
        let alertController = UIAlertController(title: "変更確認", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        // OKボタン選択時の処理
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            var myAddress = Auth.auth().currentUser?.email
            myAddress = myAddress?.replacingOccurrences(of: ".", with: ",")
            let ref = Database.database().reference().child("users").child(myAddress!).child("request").child("\(indexPath.row)")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let requestCheck: String = snapshot.childSnapshot(forPath: "requestCheck").value! as! String
                if requestCheck == "ok" {   // 許可 -> 不許可
                    let setPostData = ([
                        "requestCheck": "no"
                    ])
                    ref.updateChildValues(setPostData)
                    self.performSegue(withIdentifier: "requestBack", sender: nil)
                } else {    // 不許可 -> 許可
                    let setPostData = ([
                        "requestCheck": "ok"
                    ])
                    ref.updateChildValues(setPostData)
                    self.performSegue(withIdentifier: "requestBack", sender: nil)
                }
            })
        }
        
        // キャンセルボタン選択時の処理
        let cancelButton = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: nil)
        
        // 各ボタンの追加
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        
        present(alertController,animated: true,completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

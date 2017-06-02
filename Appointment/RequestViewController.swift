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

        return postData == nil ? 0 : postData.request.allKeys(forValue: "no").count
    }
    
    // Auto Layoutを使ってセルの高さを動的に変更する
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! RequestTableViewCell
        let requestText = postData.request.allKeys(forValue: "no")

        let changeText = requestText.reduce("") { $0 + String($1) }
        cell.setPostData(request: "\(changeText)")
        
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter({ $1 == val }).map({ $0.0 })
    }
}

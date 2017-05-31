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
    
    var postArray: [PostData] = []
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
                            self.postArray.insert(self.postData, at: 0)
                            
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
                postArray = []
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
    
    // Auto Layoutを使ってセルの高さを動的に変更する
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! RequestTableViewCell
        cell.setPostData(request: postData.request)
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

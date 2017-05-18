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

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var addFavoriteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var postArray: [PostData] = []
    var postData: PostData!
    var observing = false
    
    var selectedData: String = ""
    
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
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if FIRAuth.auth()?.currentUser != nil {
            if self.observing == false {
                // チェック用アドレス
                var address = FIRAuth.auth()?.currentUser?.email
                address = address!.replacingOccurrences(of: ".", with: ",")
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
                postsRef.observe(.childAdded, with: { (snapshot) in
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
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
                FIRDatabase.database().reference().removeAllObservers()
                observing = false
            }
        }
    }
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData == nil ? 0 : postData.favorite.count
    }
    
    // Auto Layoutを使ってセルの高さを動的に変更する
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        selectedData = postData.favorite[indexPath.row]["userMailAddress"]!
        selectedData = selectedData.replacingOccurrences(of: ".", with: ",")
        // favoriteBackで画面遷移
        performSegue(withIdentifier: "favoriteBack", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "favoriteBack") {
            // タップされたセルのお気に入りデータをdelegateLocationに渡す
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.delegateLocation = (
                delegateAddress: "\(selectedData)",
                delegateLatitude: appDelegate.delegateLocation.delegateLatitude,
                delegateLongitude: appDelegate.delegateLocation.delegateLongitude
            )
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

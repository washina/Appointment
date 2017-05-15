//
//  FavoriteViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/05/02.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var addFavoriteButton: UIButton!
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
        self.addFavoriteButton.backgroundColor = UIColorFromRGB(rgbValue: 0x40e0de)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "FavoriteTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if FIRAuth.auth()?.currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")//.child("abc@abc,jp")
                postsRef.observe(.childAdded, with: { (snapshot) in
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        self.postData = PostData(snapshot: snapshot, myId: uid)     // ここでpostDataが上書きされる
                        self.postArray.insert(self.postData, at: 0)     //先頭に値を入れる
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        self.postData = PostData(snapshot: snapshot, myId: uid)
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == self.postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        self.postArray.remove(at: index)
                        self.postArray.insert(self.postData, at: index)
                        self.tableView.reloadData()
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
        return postData == nil ? 0 : postData.favorite.count        // 現在5が返って1に上書きされる
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

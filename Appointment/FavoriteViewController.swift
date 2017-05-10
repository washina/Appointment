//
//  FavoriteViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/05/02.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addFavoriteButton: UIButton!
    
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
        
        var hostMailAddress = FIRAuth.auth()?.currentUser?.email
        hostMailAddress = hostMailAddress?.replacingOccurrences(of: ".", with: ",")
        let postRef = FIRDatabase.database().reference().child("users").child(hostMailAddress!).child("favorite")
        postRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for var loopCount in  0 ..< snapshot.childrenCount {
                
            }
        })

    }
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    }
    
    //セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

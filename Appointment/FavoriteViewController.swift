//
//  FavoriteViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/05/02.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController {

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

        // 背景色変更
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xeeeeee)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

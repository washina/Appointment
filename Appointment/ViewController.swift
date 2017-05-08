//
//  ViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/04/25.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase
import ESTabBarController

class ViewController: UIViewController {
    
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

        // Tabを表示させる処理へ
        setupTab()

    }
    
    func setupTab() {
        // 画像のファイル名を指定してESTabBarControllerを作成する
        let tabBarController: ESTabBarController! = ESTabBarController(tabIconNames: ["map", "pintopin", "favorite"])
        
        // 背景色、選択時の色を設定する
        tabBarController.buttonsBackgroundColor = UIColorFromRGB(rgbValue: 0x40e0d0)
        tabBarController.selectedColor = UIColorFromRGB(rgbValue: 0xff8c00)
        
        // 作成したESTabBarControllerを親のViewController(=self)に追加する
        addChildViewController(tabBarController)
        view.addSubview(tabBarController.view)
        tabBarController.view.frame = view.bounds
        tabBarController.didMove(toParentViewController: self)
        
        // タブをタップしたときに表示するViewControllerを設定する
        let slideViewController = storyboard?.instantiateViewController(withIdentifier: "Map")
        //let appointmentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Appointment")
        let favoriteViewController = storyboard?.instantiateViewController(withIdentifier: "Favorite")
        
        tabBarController.setView(slideViewController, at: 0)
        //tabBarController.setView(appointmentViewController, at: 1)
        tabBarController.setView(favoriteViewController, at: 2)
        
        
        // 真ん中のタブはボタンとして扱う
        tabBarController.highlightButton(at: 1)
        tabBarController.setAction({
            // ボタンが押されたらImageSelectViewControllerをモーダルで表示する
            let appointmentController = self.storyboard?.instantiateViewController(withIdentifier: "Appointment")
            self.present(appointmentController!, animated: true, completion: nil)
        }, at: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* 起動時画面遷移処理 ----------------------------------------------------------------------------------*/
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if FIRAuth.auth()?.currentUser == nil {
            // ログインしていなければLoginViewControllerへ
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
    }
    /* 起動時画面遷移処理 ----------------------------------------------------------------------------------*/

}


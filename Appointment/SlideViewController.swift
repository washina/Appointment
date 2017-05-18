//
//  SlideViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/05/02.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class SlideViewController: SlideMenuController {
    
    // スライド時の背景を生成
    override func awakeFromNib() {
        let mainVC = storyboard?.instantiateViewController(withIdentifier: "Map") as! MapViewController
        let rightVC = storyboard?.instantiateViewController(withIdentifier: "Right") as! RightMenuViewController
        // UIViewControllerにはNavigationBarは無いためUINavigationControllerを生成
        let navigationController = UINavigationController(rootViewController: mainVC)
        // ライブラリ特有のプロパティにセット
        mainViewController = navigationController
        rightViewController = rightVC
        
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


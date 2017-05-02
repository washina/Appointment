//
//  ViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/04/25.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print()
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
        } else {
            // ログインしていればSlideViewController(MapViewController)へ
            let slideViewController = self.storyboard?.instantiateViewController(withIdentifier: "Slide")
            self.present(slideViewController!, animated: true, completion: nil)
        }
    }
    /* 起動時画面遷移処理 ----------------------------------------------------------------------------------*/

}


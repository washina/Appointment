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
            DispatchQueue.main.async {
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                self.present(loginViewController!, animated: true, completion: nil)
            }
        } else {
            // ログインしていればMapViewControllerへ
            DispatchQueue.main.async {
                let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "Map")
                self.present(mapViewController!, animated: true, completion: nil)
            }
        }
    }
    /* 起動時画面遷移処理 ----------------------------------------------------------------------------------*/

}


//
//  AppointmentViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/04/25.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase

class AppointmentViewController: UIViewController {
    
    // アウトレット接続
    @IBOutlet weak var toMailAddressTextField: UITextField!
    @IBOutlet weak var viewPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // 完了ボタンが押されたときにキーボードを隠す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // ボタンを押す度にランダムな16桁の英数字を発行
    @IBAction func randomPasswordButton(_ sender: Any) {
        let randomPass = random(length: 16)
        viewPasswordTextField.text = randomPass
    }
    
    // ランダムな英数字を作るメソッド
    func random(length: Int) -> String {
        let alphabet = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(alphabet.characters.count)
        return String((0..<length).map { _ -> Character in
            return alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))]
        })
    }
    
    
    @IBAction func sendRequestButton(_ sender: Any) {
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

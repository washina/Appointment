//
//  RightMenuViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/05/02.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit

class RightMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let texts = ["使い方", "アカウント", "リクエスト"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    //セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = texts[indexPath.row]
        return cell
    }
    
    // それぞれのセルが選択されたときに各画面へ遷移させる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {             // 「使い方」がタップされた時
            let howToVC = self.storyboard?.instantiateViewController(withIdentifier: "HowTo")
            self.present(howToVC!, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.row == 1 {      // 「アカウント」がタップされた時
            let plofileSettingVC = self.storyboard?.instantiateViewController(withIdentifier: "Plofile")
            self.present(plofileSettingVC!, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.row == 2 {      // 「リクエスト」がタップされた時
            let requestVC = self.storyboard?.instantiateViewController(withIdentifier: "Request")
            self.present(requestVC!, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
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

//
//  FavoriteTableViewCell.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/05/17.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userMailAddressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPostData(favorite: [String:String]) {
        self.userNameLabel.text = "名前：" + favorite["userName"]!
        self.userMailAddressLabel.text = "アドレス：" + favorite["userMailAddress"]!
    }

}

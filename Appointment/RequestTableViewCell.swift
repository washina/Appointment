//
//  RequestTableViewCell.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/05/31.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase

class RequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPostData(request: String) {
        self.addressLabel.text = request
    }

}

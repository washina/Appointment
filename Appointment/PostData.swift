//
//  PostData.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/05/12.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String?
    var favorite = [[String:String]]()
    var latitude: Double?
    var longitude: Double?
    var token: String?
    
    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        if let favorite = valueDictionary["favorite"] as? [[String: String]] {
            self.favorite = favorite
        }
        
        self.latitude = valueDictionary["latitude"] as? Double
        self.longitude = valueDictionary["longitude"] as? Double
        
        self.token = valueDictionary["token"] as? String
        
    }
}

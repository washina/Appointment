//
//  PostData.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/04/28.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PostData: NSObject {
    var id: String?
    var latitude: Double?
    var longitude: Double?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        //self.latitude = valueDictionary["latitude"] as? Double
        
        //self.longitude = valueDictionary["longitude"] as? Double
        
    }
}

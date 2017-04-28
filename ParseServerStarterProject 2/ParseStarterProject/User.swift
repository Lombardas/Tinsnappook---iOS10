//
//  User.swift
//  Tinsnappok
//
//  Created by Tasio on 15/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreLocation

class User: NSObject {
    
    var objectID : String!
    var name : String!
    var email : String!
    var isFriend : Bool = false
    
    var birthDate : Date?
    var gender : Bool?
    
    var image : UIImage?
    
    var location : CLLocationCoordinate2D?
    
    init(objectID: String,name: String, email: String){
        self.name = name
        self.email = email
        self.objectID = objectID
    }
    
}

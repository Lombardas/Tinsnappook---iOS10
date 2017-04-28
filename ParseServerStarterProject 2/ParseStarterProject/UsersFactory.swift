//
//  UsersFactory.swift
//  Tinsnappok
//
//  Created by Tasio on 21/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class UsersFactory: NSObject {
    static let sharedInstance = UsersFactory()
    static let notificationName = Notification.Name("UsersLoaded")
    
    
    var currentUser : User?
    var users : [User] = []
    
    override init() {
        super.init()
        self.loadUsers()
        self.loadMainuser()
    }
    
    func getUsers() -> [User]
    {
        self.loadUsers()
        self.loadMainuser()
        return self.users
    }
    
    func loadMainuser(){
        
        let pfUser = PFUser.current()
        let objectID = pfUser?.objectId
        let defaultUserName = pfUser?.username?.components(separatedBy:"@")[0]
        let customUserName = pfUser?["nickname"]
        let email = pfUser?.email
        
        
       // let imageFile = currentUser["imageFile"] as! PFFile
        
        
        
        self.currentUser = User(objectID: objectID!, name: ((customUserName == nil) ? defaultUserName : customUserName)! as! String, email: email!)
        
        
        if let gender = pfUser?["gender"] as? Bool{
            self.currentUser!.gender = gender
        }
        
        if let birthDate = pfUser?["birthDate"] as? Date{
            self.currentUser!.birthDate = birthDate
        }
        
        if let imageFile = pfUser?["imageFile"] as? PFFile {
            imageFile.getDataInBackground { (data, error) in
                if let data = data{
                    self.currentUser!.image = UIImage(data: data)
                }
            }
            
            
        }
        
        PFGeoPoint.geoPointForCurrentLocation { (geopoint, error) in
            if let geopoint = geopoint {
               
                self.currentUser?.location = CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
                
                PFUser.current()?["geopoint"] = geopoint
                PFUser.current()?.saveInBackground()
                
               // pfUser?["geopoint"] = geopoint
               // pfUser?.saveInBackground()
            
            }
        }
    }
    
    func loadUsers()
    {
        let query = PFUser.query()
        query?.whereKey("objectID", notEqualTo: PFUser.current()?.objectId as Any)
        
        let Geopoint = PFUser.current()?["geopoint"] as? PFGeoPoint
        
        
        
        
       // query?.whereKey("geopoint", withinGeoBoxFromSouthwest: PFGeoPoint(latitude:(Geopoint?.latitude)!,longitude:(Geopoint?.longitude)!-1), toNortheast: PFGeoPoint(latitude: (Geopoint?.latitude)!+1 , longitude: (Geopoint?.longitude)!+1))
        
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil{
                print("Error de consulta\(error?.localizedDescription as Any)")
            } else{
                self.users.removeAll()
                for object in objects! {
                    if let user = object as? PFUser{
                        
                        
                        if user.objectId != PFUser.current()?.objectId
                        {
                            
                            let email = user.username
                            
                            let defaultUserName = user.username?.components(separatedBy:"@")[0].capitalized
                            let customUserName = user["nickname"]
                            
                            
                            
                            let objectID = user.objectId!
                            let myUser = User(objectID: objectID,name: (customUserName != nil ? customUserName : defaultUserName)! as! String, email: email!)
                            
                            let geopoint = user["geopoint"] as! PFGeoPoint
                            let location = CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
                            
                            myUser.location = location
                            
                            
                            
                            if let gender = user["gender"] as? Bool {
                                myUser.gender = gender
                            
                            }
                            
                            if let birthdate = user["birthdate"] as? Date {
                                myUser.birthDate = birthdate
                            
                            }
                            
                            if let imageFile = user["imageFile"] as? PFFile {
                                imageFile.getDataInBackground { (data, error) in
                                    if let data = data{
                                        print("entrada en data: \(data)")
                                        myUser.image = UIImage(data: data)
                                        
                                    }
                                }
                                
                                
                            }
                            
                            
                            let query = PFQuery(className: "UserFriends")
                            
                            query.whereKey("idUser", equalTo: PFUser.current()?.objectId! as Any)
                            query.whereKey("idUserFriend", equalTo: myUser.objectID)
                            
                            // query.whereKey("idUser", equalTo: "2oexYi6iae")
                            // query.whereKey("idUserFriend", equalTo: "d8FQgYIW9z")
                            
                            query.findObjectsInBackground(block: { (objects, error) in
                                if error != nil{
                                    
                                } else {
                                    
                                    print("ha ido a else de no error")
                                    if let objects = objects
                                    {
                                        // print("\(myUser.objectID)")
                                        // print("\(PFUser.current()?.objectId!)")
                                        if objects.count > 0{
                                            myUser.isFriend = true
                                            print("myUser.isFriend = \(myUser.isFriend)")
                                        }
                                    }
                                }
                            })
                            
                            self.users.append(myUser)
                            
                        }
                    }
                }//end for
                NotificationCenter.default.post(name: UsersFactory.notificationName, object: nil)
                
            }
            
        })
        
    }//end load users

    
    func getFriends() -> [User]
    {
        
        
        var friends : [User] = []
        
        for user in self.users{
            
            if user.isFriend
            {
                friends.append(user)
            }
        }
        return friends
    }
    
    func getUnknownPeople() -> [User]
    {
       
        
        var nofriends : [User] = []
        
        for user in self.users{
            
            if !user.isFriend
            {
                nofriends.append(user)
            }
        }
        return nofriends
    }
    
    func findUser(idUser: String) -> User?
    {
        for user in self.users
        {
            if user.objectID == idUser
            {
                return user
            }
        }
        
        return nil
    }
    
    
    func findUserAt(index: Int) -> User?
    {
        
        if (index >= 0 && index < self.users.count)
        {
            return self.users[index]
        }
        return nil
    }
    
}

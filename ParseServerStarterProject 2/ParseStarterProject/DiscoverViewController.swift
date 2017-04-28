//
//  DiscoverViewController.swift
//  Tinsnappok
//
//  Created by Tasio on 14/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class DiscoverViewController: UIViewController {

    
    var users : [User] = []
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var idx = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil{
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        users = UsersFactory.sharedInstance.getUnknownPeople()
        
        reloadView()
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DiscoverViewController.imageDragged(gestureRecognizer : )))
        
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func reloadView()
    {
        
        idx += 1
        if idx >= self.users.count
        {
            idx = 0
        }
        
        
        let user = users[idx]
        self.userNameLabel.text = user.name
        if let image = user.image
        {
            self.userImageView.image = image
        } else {
            self.userImageView.image = #imageLiteral(resourceName: "no-friend")
        }
        
    }
    
    
    func imageDragged(gestureRecognizer: UIPanGestureRecognizer)
    {
        let translation = gestureRecognizer.translation(in: self.view)
        let imageView = gestureRecognizer.view!
        
        imageView.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: self.view.bounds.height/2 + translation.y)
        
        let rotationAngle = (imageView.center.x - self.view.bounds.width/2)/180.0
        var rotation = CGAffineTransform(rotationAngle: rotationAngle)
        let scaleFactor = min(80/abs(imageView.center.x - self.view.bounds.width/2),1)
        
        
        var scaleAndRotate = rotation.scaledBy(x: scaleFactor, y: scaleFactor)
        
        imageView.transform = scaleAndRotate
        
        
        
        
        if gestureRecognizer.state == .ended {
            
            if imageView.center.x < 100 {
                print("debemos rechazar al usuario")
                self.reloadView()
            }
            if imageView.center.x >= self.view.bounds.width - 100 {
                print("debemos seguir al usuario")
                self.users[idx].isFriend = true
                
                let friendship = PFObject(className: "UserFriends")
                friendship["idUser"] = PFUser.current()?.objectId
                friendship["idUserFriend"] = self.users[idx].objectID
                
                friendship.saveInBackground()
                
                self.users = UsersFactory.sharedInstance.getUnknownPeople()
                
                self.reloadView()
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            scaleAndRotate = rotation.scaledBy(x: 1, y: 1)
            imageView.transform = scaleAndRotate
            imageView.center = CGPoint(x: self.view.bounds.width/2 , y: self.view.bounds.height/2)
            
        }
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

//
//  FriendsViewController.swift
//  Tinsnappok
//
//  Created by Tasio on 14/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class FriendsViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var users : [User] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil{
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Tira para recargar amigos")
        self.refreshControl?.addTarget(self, action: #selector(FriendsViewController.loadUsers), for: .valueChanged)
        
              // createBots()
        
        
       self.loadUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadUsers()
    }
    
    
    func createBots()
    {
        
        let urls = ["Sara":"http://metodosparaligar.com/wp-content/uploads/2011/08/tecnica-para-seducir-una-mujer.jpg",
                    "Vanesa":"http://imatclinic.com/wp-content/uploads/2015/01/belleza-mujer1.jpg",
                    "Sofia": "http://www.lavidalucida.com/wp-content/uploads/2015/05/Mujer-pelo-rizos-peinado.jpg",
                    "Monica" : "http://elcerebrohabla.com/wp-content/uploads/mujer-feliz-1024x878.jpg",
                    "Antonia": "https://i.ytimg.com/vi/D00f6q4xwn0/hqdefault.jpg"]
        

        
        for (name,profileURL) in urls
        {
            let user = PFUser()
            
            user.username = name + "@bot.com"
            user.email = name + "@bot.com"
            user.password = "bot1234"
            user["gender"] = false
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            user["birthdate"] = formatter.date(from: "01-01-1989")
            
            let url = URL(string: profileURL)
            do {
                
                let data = try Data(contentsOf: url!)
                user["imageFile"] = PFFile(name: "bot.jpeg", data: data)
            } catch {
                
                print("No hemos podido recuperar las imágenes")
            }
            
            user.signUpInBackground(block: { (success, error) in
                if(success)
                {
                    print("perfil creado correctamente")
                }
            })
            
        }

        
    }
    
    func loadUsers()
    {
        
         self.users = UsersFactory.sharedInstance.getFriends()
         self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }//end load users
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell",for: indexPath) as! UserTableViewCell
        
        let user = self.users[indexPath.row] //UsersFactory.sharedInstance.findUserAt(index: indexPath.row)!
        
        cell.userNameLabel.text = user.name
        
        if let image = user.image {
            cell.userImageView.image = image
        } else {
        
            cell.userImageView.image = #imageLiteral(resourceName: "no-friend")
        }
        
        cell.userImageView.layer.cornerRadius = 30
        cell.userImageView.clipsToBounds = true
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexpath: IndexPath) {
        
//        let cell = tableView.cellForRow(at: indexpath)
//        
//        if self.users[indexpath.row].isFriend{
//            cell?.accessoryType = .none
//            
//            self.users[indexpath.row].isFriend = false
//            
//            let query = PFQuery(className: "UserFriends")
//            query.whereKey("idUser", equalTo: PFUser.current()?.objectId!)
//            query.whereKey("idUserFriend", equalTo: self.users[indexpath.row].objectID)
//            
//            query.findObjectsInBackground(block: { (objects, error) in
//                if error != nil{
//                    print(error?.localizedDescription as Any)
//                    
//                } else {
//                    if let objects = objects {
//                        
//                        for object in objects
//                        {
//                            object.deleteInBackground()
//                        }
//                    
//                    }
//                
//                }
//            })
//            
//        }else {
//            
//            cell?.accessoryType = .checkmark
//            self.users[indexpath.row].isFriend = true
//            
//            let friendship = PFObject(className: "UserFriends")
//            friendship["idUser"] = PFUser.current()?.objectId
//            friendship["idUserFriend"] = self.users[indexpath.row].objectID
//            
//            friendship.saveInBackground()
//        }
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        if segue.identifier == "showDetail"{
            let destinationVC = segue.destination as! PublicProfileViewController
            
            destinationVC.user = self.users[(self.tableView.indexPathForSelectedRow?.row)!]
        }
     }
    
    

}

//
//  FeedViewController.swift
//  Tinsnappok
//
//  Created by Tasio on 13/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var posts : [Post] = []
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil{
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //self.requestPosts()
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = UIRefreshControl()
            self.tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Tira para recargar posts")
            self.tableView.refreshControl?.addTarget(self, action: #selector(FeedViewController.requestPosts), for: .valueChanged)
        }
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(FeedViewController.askForDirectPhotos), userInfo: nil, repeats: true)
    }
    
    
    func askForDirectPhotos()
    {
        let query = PFQuery(className: "DirectImage")
        
        query.whereKey("idUserReceiver", equalTo: (PFUser.current()?.objectId)!)
        
        do {
            let images = try query.findObjects()
            
            if images.count > 0 {
                let image = images.first!
                var receiver : User? = nil
                if let idUserSender = image["idUserSender"] as? String
                {
                    receiver = UsersFactory.sharedInstance.findUser(idUser: idUserSender)
                }
                
                if let PFFile = image["image"] as? PFFile {
                    PFFile.getDataInBackground(block: { (data, error) in
                        if let imageData = data{
                            self.timer.invalidate()
                            image.deleteInBackground()
                            		
                            if let imageToShow = UIImage(data: imageData)
                            {
                                let alertController = UIAlertController(title: "Tienes un nuevo mensaje", message: "Has recibido un mensaje de \(receiver?.name)", preferredStyle: .alert)
                                
                                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    
                                    let backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    backgroundImageView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                                    backgroundImageView.alpha = 0.8
                                    self.view.addSubview(backgroundImageView)
                                    backgroundImageView.tag = 28
                                    
                                    let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    imageview.image = imageToShow
                                    imageview.contentMode = .scaleAspectFit
                                    self.view.addSubview(imageview)
                                    imageview.tag = 28
                                    
                                    if #available(iOS 10.0, *) {
                                        _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                                            
                                             self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(FeedViewController.askForDirectPhotos), userInfo: nil, repeats: true)
                                            
                                            for v in self.view.subviews
                                            {
                                                if v.tag == 28
                                                {
                                                    v.removeFromSuperview()
                                                }
                                            
                                            }
                                        })
                                    }
                                    
                                    
                                })
                                
                                alertController.addAction(alertAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    })
                }
                
            }
            
        } catch {
            print("Ha habido un error al buscar imágenes directas")
        }
    }
    
    
    func requestPosts()
    {
        let query = PFQuery(className: "Post")
        query.whereKey("idUser", notEqualTo: PFUser.current()?.objectId! as Any)
        query.order(byDescending: "createdAt")
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                print(error?.localizedDescription as Any)
            } else {
                
                if let objects = objects{
                    self.posts.removeAll()
                    for object in objects
                    {
                        let objectID = object.objectId!
                        let message = object["message"] as! String
                        let creationDate = object.createdAt!
                        
                        let postPosition = self.posts.count
                        let post : Post = Post(objectID: objectID, message: message, image: nil, user: nil, creationDate: creationDate)
                        self.posts.append(post)
                        
                        
                        
                        let imageFile = object["imageFile"] as! PFFile
                        imageFile.getDataInBackground(block: { (data, error) in
                            if let data = data {
                                let downloadedImage = UIImage(data: data)
                                self.posts[postPosition].image = downloadedImage
                                
                                self.tableView.reloadData()
                                if #available(iOS 10.0, *) {
                                    self.tableView.refreshControl?.endRefreshing()
                                }
                            
                            }
                        })
                        // definir el usuario del post.
                        let idUser = object["idUser"] as! String
                        
                        if let user = UsersFactory.sharedInstance.findUser(idUser: idUser)
                        {
                            self.posts[postPosition].user = user
                        }/* else{
                            
                            let username = PFUser.current()?.username?.components(separatedBy: "@")[0]

                            self.posts[postPosition].user = User(objectID: (PFUser.current()?.objectId)!, name: username!, email: (PFUser.current()?.email!)!)
                        }*/
                    }
                }
                
            }
        }
    
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.requestPosts), name: UsersFactory.notificationName, object: nil)
        
        _ = UsersFactory.sharedInstance.getUsers()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UsersFactory.notificationName, object: nil)
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

extension FeedViewController : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as! FeedTableViewCell
        let post = self.posts[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        
        
        cell.dateLabel.text = formatter.string(from: post.creationDate)
        cell.contentLabel.text = post.message
        
        if post.user != nil
        {
            cell.userName.text = post.user?.name.capitalized
           // print("antes de carga de foto")
            
            if  let image = post.user?.image{
                print(image)
                cell.userImageView.image = image
            }
            
            cell.userImageView.layer.cornerRadius = 17
            cell.userImageView.clipsToBounds = true
            
        }
        if post.image != nil
        {
            cell.postImageView.image = post.image
        }
        
        
        return cell
    }
    
    
    
}

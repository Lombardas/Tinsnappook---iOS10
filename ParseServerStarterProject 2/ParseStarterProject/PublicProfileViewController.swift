//
//  PublicProfileViewController.swift
//  Tinsnappok
//
//  Created by Tasio on 25/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class PublicProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var user : User?
    var posts : [Post] = []
    
    var activityIndicator : UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var birthdateLabel: UILabel!
    @IBOutlet weak var friendsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Vamos a mostrar el perfil de" + (user?.name)!)
        // Do any additional setup after loading the view.
        
        if let image = user?.image {
        self.userImageView.image = image
        } else {
            self.userImageView.image = #imageLiteral(resourceName: "no-friend")
        }
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2.0
        self.userImageView.clipsToBounds = true

        
        self.usernameLabel.text = user?.name
        if let birthdate = user?.birthDate{
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            
            self.birthdateLabel.text = "Nacido el \(formatter.string(from: birthdate))"
        } else {
            self.birthdateLabel.text = "Fecha de nacimiento desconocida."
        }
        
        if let gender = user?.gender {
            if gender {
                self.friendsButton.setImage(#imageLiteral(resourceName: "friend-female"), for: .normal)
                
            } else {
                self.friendsButton.setImage(#imageLiteral(resourceName: "friend-male"), for: .normal)
            }
        }
        
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = UIRefreshControl()
            self.tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Tira para recargar posts")
            self.tableView.refreshControl?.addTarget(self, action: #selector(FeedViewController.requestPosts), for: .valueChanged)
        }
        
        self.requestPosts()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func requestPosts()
    {
        let query = PFQuery(className: "Post")
       // query.whereKey("idUser", EqualTo: (user?.objectID)!)
        query.whereKey("idUser", equalTo: user?.objectID! as Any)
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
                       
                        post.user = self.user
                        
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
                       
                    }
                }
                
            }
        }
        
    }

    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showUserLocation"
        {
            let destinationVC = segue.destination as! UserMapViewController
            
            destinationVC.user = self.user
        }
    
    }
    
    @IBAction func showLocation(_ sender: UIButton) {
    }
    @IBAction func frienddButton(_ sender: UIButton) {
        
        self.user?.isFriend = false
        self.friendsButton.setImage(#imageLiteral(resourceName: "no-friend"), for: .normal)
                    let query = PFQuery(className: "UserFriends")
                    query.whereKey("idUser", equalTo: (PFUser.current()?.objectId!) as Any)
                    query.whereKey("idUserFriend", equalTo: self.user?.objectID as Any)
        
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error != nil{
                            print(error?.localizedDescription as Any)
        
                        } else {
                            if let objects = objects {
        
                                for object in objects
                                {
                                    object.deleteInBackground()
                                }
                            
                            }
                        
                        }
                    })

    }
    @IBAction func chatButton(_ sender: UIButton) {
    }
    @IBAction func sendPicture(_ sender: UIButton) {
        
        
        
        let alertController = UIAlertController(title: "Selecciona una imagen", message: "¿De dónde deseas seleccionar la imagen?", preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action) in
            self.loadFromLibrary()
        }
        alertController.addAction(libraryAction)
        
        
        let cameraAction = UIAlertAction(title: "Cámara de fotos", style: .default) { (action) in
            self.takePhoto()
        }
        alertController.addAction(cameraAction)
        
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadFromLibrary(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true,completion: nil)
        
    }
    
    func takePhoto()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true,completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.startActivityIndicator()
            let directImage = PFObject(className: "DirectImage")
            directImage["image"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.8)!)
            directImage["idUserSender"] = UsersFactory.sharedInstance.currentUser?.objectID
            directImage["idUserReceiver"] = self.user?.objectID
            
            
            let acl = PFACL()
            acl.getPublicReadAccess = true
            acl.getPublicWriteAccess = true
            directImage.acl = acl
            
            
            directImage.saveInBackground(block: { (success, error) in
                var title = "Envío fallido"
                var message = "Por favor, inténtalo de nuevo más tarde"
                
                if success {
                    title = "Imagen enviada"
                    message = "Tu imagen se ha enviado correctamente"
                }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self.stopActivityIndicator()
                self.present(alertController, animated: true, completion: nil)
            })
        }
            self.dismiss(animated: true, completion: nil)
    }
    
   
    
    /*ACTIVITY CONTROLLER******************/
    
    func startActivityIndicator()
    {
        //uso del activityIndicator
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 5, height: 50))
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        self.view.addSubview(self.activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.activityIndicator.startAnimating()
        
    }
    
    func stopActivityIndicator()
    {
        //parar el activity
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
    }
    
    /***FIN ACTIVITY CONTROLLER******************/

    
    
    
    
}
    


extension PublicProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.posts.count
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
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

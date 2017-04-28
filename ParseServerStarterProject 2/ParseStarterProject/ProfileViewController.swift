//
//  ProfileViewController.swift
//  Tinsnappok
//
//  Created by Tasio on 14/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameTexfield: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderSwith: UISwitch!
    @IBOutlet weak var birthdateLabel: UIButton!
    
    var user : User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.nameTexfield.delegate = self
        
        if self.revealViewController() != nil{
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        user = UsersFactory.sharedInstance.currentUser!
        
        self.nameTexfield.text = user?.name.capitalized
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        user = UsersFactory.sharedInstance.currentUser!
        
       // self.nameTexfield.text = user?.name.capitalized
        
        if let image = user?.image {
            self.userImageView.image = image
        } else
        {
            self.userImageView.image = #imageLiteral(resourceName: "no-friend")
        }
        
        
        if let birthdate = user?.birthDate {
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            
            self.birthdateLabel.setTitle(dateFormatter.string(from: birthdate), for: .normal)
        } else {
            self.birthdateLabel.setTitle("Desconocida", for: .normal)
        }
        
        if let gender = user?.gender {
            
            if gender == true{
                self.genderSwith.isOn = true
                self.genderLabel.text = "Mujer"
            } else {
                self.genderSwith.isOn = false
                self.genderLabel.text = "Hombre"
            }
            
        } else {
            self.genderLabel.text = "Desconocido"
            
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        
        PFUser.logOut()
        performSegue(withIdentifier: "logout", sender: nil)
    }
   
     @IBAction func pickPhoto(_ sender: UIButton) {
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
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
           // self.userImageView.image = image
            self.user?.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
   
        
     
     @IBAction func swithChanged(_ sender: UISwitch) {
        
        self.user?.gender = self.genderSwith.isOn
        if genderSwith.isOn{
            self.genderLabel.text = "Mujer"
        } else {
            self.genderLabel.text = "Hombre"
        }
        
        
     }
    @IBAction func saveToParse(_ sender: UIButton) {
        
        let pfuser = PFUser.current()!
        
        pfuser["nickname"] = self.nameTexfield.text
        pfuser["gender"] = self.user?.gender
        pfuser["birthDate"] = self.user?.birthDate
        
        let imageData = UIImageJPEGRepresentation(self.userImageView.image!, 0.8)
        let imageFile = PFFile(name: pfuser.username!+".jpg", data: imageData!)
        
        pfuser["imageFile"] = imageFile
        
        pfuser.saveInBackground { (success, error) in
            if success{
                let ac = UIAlertController(title: "Usuario Actualizaro", message: "Tu usuario se ha actualizado correctamente", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                ac.addAction(okAction)
                self.present(ac, animated: true, completion: nil)
            
            }
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

extension ProfileViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

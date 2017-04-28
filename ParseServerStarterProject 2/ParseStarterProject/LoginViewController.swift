/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    var activityIndicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
     /*   let user = PFObject(className: "Users")
        
        user["name"] = "Juan"
        user.saveInBackground { (success, error) in
            if success {
                print("El usuario se ha creado correctamente en Parse")
            }
            else
            {
                if error != nil {
                    print(error?.localizedDescription)
                }
                else{
                    print("Error Desconocido")
                }
            }
            
            
        }*/
        
        let query = PFQuery(className: "Users")
        query.getObjectInBackground(withId: "DCbb4poDqC") { (object, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            else{
                if let user = object {
                    print(user)
                    user["name"] = "Juan Pedro"
                    user.saveInBackground(block: { (success, error) in
                        if success {
                            print("Hemos modificado el usuario")
                        } else {
                            print(error?.localizedDescription as Any)
                        }
                    })
                }
            }
        }
 
        //Descomenta esta linea para probar que Parse funciona correctamente
        //self.testParseSave()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.current() != nil{
            self.performSegue(withIdentifier: "goToMainVC", sender: nil)
        
        }
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    @IBAction func recoverPassword(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Recuperar contraseña", message: "Introduce el email de registro en Tinsnappook", preferredStyle: .alert)
        alertController.addTextField{(textfield) in
        
            textfield.placeholder = "Introduce aquí tu email"
        }
        let okAction = UIAlertAction(title: "Recuperar contraseña", style: .default) { (action) in
            let theEmail = alertController.textFields![0] as UITextField
            
            PFUser.requestPasswordResetForEmail(inBackground: theEmail.text!, block: { (succes, error) in
                if error != nil{
                    var errorMessage = "Inténtalo de nuevo, ha habido un error al recuperar la contraseña"
                    if let parseError = error?.localizedDescription {
                        errorMessage = parseError
                    }
                    self.createAlert(titl: "Error de recuperación", message: errorMessage)
                    
                }
                else
                {
                    self.createAlert(titl: "Contraseña recuperada", message: "Mira tu bandeja de entrada de  \(theEmail.text!) y sigue las instrucciones indicadas")
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Ahora no", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    @IBAction func loginPressed(_ sender: UIButton) {
        if infoCompleted(){
            
            startActivityIndicator()
            //Procedemos a logear al usuario
            PFUser.logInWithUsername(inBackground: self.emailTextField.text!, password: self.passwordTextField.text!, block: { (user, error) in
                
                self.stopActivityIndicator()
                
                if error != nil{
                    var errorMessage = "Inténtalo de nuevo, ha habido un error de login"
                    if let parseError = error?.localizedDescription {
                        errorMessage = parseError
                    }
                    self.createAlert(titl: "Error de login", message: errorMessage)
                    
                }
                else
                {
                    print("Hemos entrado correctamente")
                    self.performSegue(withIdentifier: "goToMainVC", sender: nil)
                }
            })
        }

    }
    @IBAction func singupPressed(_ sender: UIButton) {
        
        if infoCompleted()
        {
            
           self.startActivityIndicator()
            
            //Procedemos a registrar al usuario.
            //PFUser
            
            let user = PFUser()
            user.username = self.emailTextField.text
            user.email = self.emailTextField.text
            user.password = self.passwordTextField.text
            
            //mandarlos al servidor (guardar)
            user.signUpInBackground(block: { (succes, error) in
                
                self.stopActivityIndicator()
                
                if error != nil{
                    var errorMessage = "Inténtalo de nuevo, ha habido un error"
                    if let parseError = error?.localizedDescription {
                        errorMessage = parseError
                    }
                    self.createAlert(titl: "Error de registro", message: errorMessage)
                    
                }else{
                    print("Usuario registrado correctamente")
                    self.performSegue(withIdentifier: "goToMainVC", sender: nil)
                }
            })
        }
        
    }
    
    func infoCompleted() -> Bool
    {
        var infoCompleted = true
        if self.emailTextField.text == "" || self.passwordTextField.text == ""{
            infoCompleted = false
            
            self.createAlert(titl: "Verifica tus datos", message: "Asegúrate de introducir un correo y una contraseña válidos")
        }
        
        
        
        return infoCompleted
    
    }//end func
    
    func createAlert(titl: String, message: String)
    {
        //alerta
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        //fin alerta.
    }
    
    func testParseSave() {
        let testObject = PFObject(className: "MyTestObject")
        testObject["foo"] = "new-bar"
        testObject.saveInBackground { (success, error) -> Void in
            if success {
                print("El objeto se ha guardado en Parse correctamente.")
            } else {
                if error != nil {
                    print (error!)
                } else {
                    print ("Error")
                }
            }
        }
    }

    
    func startActivityIndicator()
    {
        //uso del activityIndicator
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 5, height: 50))
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = .gray
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension LoginViewController: UITextFieldDelegate
{
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

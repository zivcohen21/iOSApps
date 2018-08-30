//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD


class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextfield.isSecureTextEntry = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {

        changeUserInteraction(isEnable: false)
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) {
            
            (user, error) in
            if error != nil {
                print(error!)
            } else {
                print("Log in Successful!")
                SVProgressHUD.dismiss()
                self.changeUserInteraction(isEnable: true)
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }

    }
    
    func changeUserInteraction(isEnable: Bool) {
        navigationController?.navigationBar.isUserInteractionEnabled = isEnable
        logInButton.isUserInteractionEnabled = isEnable
        emailTextfield.isUserInteractionEnabled = isEnable
        passwordTextfield.isUserInteractionEnabled = isEnable
    }


    
}  

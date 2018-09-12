//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD


class LogInViewController: UIViewController {

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextfield.isSecureTextEntry = true
    }
    
    @IBAction func logInPressed(_ sender: AnyObject) {

        changeUserInteraction(isEnable: false)
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) {
            
            (user, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Log in Successful!")
                self.performSegue(withIdentifier: "goToChat", sender: self)
                self.emailTextfield.text = ""
                self.passwordTextfield.text = ""
            }
            SVProgressHUD.dismiss()
            self.changeUserInteraction(isEnable: true)
        }
    }
    
    func changeUserInteraction(isEnable: Bool) {
        navigationController?.navigationBar.isUserInteractionEnabled = isEnable
        logInButton.isUserInteractionEnabled = isEnable
        emailTextfield.isUserInteractionEnabled = isEnable
        passwordTextfield.isUserInteractionEnabled = isEnable
    }
}  

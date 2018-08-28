//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    //Pre-linked IBOutlets

//    @IBOutlet var emailTextfield: UITextField!
//    @IBOutlet var passwordTextfield: UITextField!
//
    @IBOutlet weak var formItemsTableView: UITableView!
    
    let userNameKey = "name"
    let phoneKey = "phone"
    let countryKey = "country"
    let cityKey = "city"
    let streetKey = "street"
    let emailKey = "email"
    let vEmailKey = "vEmail"
    let passwordKey = "password"
    let vPasswordKey = "vPassword"
    
    var keys: [String] = []
    var formItemsDict: [String: FormItem] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       formItemsDict = [
            userNameKey: FormItem(placeholder: "Full Name", isMandatory: true),
            phoneKey: FormItem(placeholder: "Phone Number", isMandatory: false),
            countryKey: FormItem(placeholder: "Country", isMandatory: false),
            cityKey: FormItem(placeholder: "City", isMandatory: false),
            streetKey: FormItem(placeholder: "Street", isMandatory: false),
            emailKey: FormItem(placeholder: "Email", isMandatory: true),
            vEmailKey: FormItem(placeholder: "Valid Email", isMandatory: true),
            passwordKey: FormItem(placeholder: "Password", isMandatory: true),
            vPasswordKey: FormItem(placeholder: "Valid Password", isMandatory: true)
        ]
        
        keys = [userNameKey, phoneKey, countryKey, cityKey, streetKey, emailKey, vEmailKey, passwordKey, vPasswordKey]
        
        formItemsTableView.delegate = self
        formItemsTableView.dataSource = self
        
        formItemsTableView.register(UINib(nibName: "FormItemTableViewCell", bundle: nil), forCellReuseIdentifier: "FormItemTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formItemsDict.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormItemTableViewCell", for: indexPath) as! FormItemTableViewCell
        if let item = formItemsDict[keys[indexPath.row]] {
            cell.initCell(item)
            item.indexPath = indexPath
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / CGFloat(formItemsDict.count)
    }
    
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        
        for (key, item) in formItemsDict {
            item.value = (formItemsTableView.cellForRow(at: item.indexPath!) as! FormItemTableViewCell).formItemTextField.text
        }
        
        if formItemsDict[emailKey]?.value == formItemsDict[vEmailKey]?.value && formItemsDict[passwordKey]?.value == formItemsDict[vPasswordKey]?.value {
            
            print(formItemsDict[emailKey]?.value)
            print(formItemsDict[passwordKey]?.value)
            Auth.auth().createUser(withEmail: (formItemsDict[emailKey]?.value)!, password: (formItemsDict[passwordKey]?.value)!) {
                (user, error) in
                if error != nil {
                    print(error!)
                }
                else {
                    //Success
                    var dictToSave: [String : String] = [:]
                    for (key, item) in self.formItemsDict {
                        dictToSave[key] = item.value
                    }
                    
                    let userDetailsDB = Database.database().reference().child("userDetails")
                    
                    userDetailsDB.childByAutoId().setValue(dictToSave) {
                        (error, reference) in
                        if error != nil {
                            print(error!)
                        }
                        else {
                            print("Details saved successfully!")
                        }
                    }
                    
                    print("Registration Successful!")
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "goToChat", sender: self)
                }
            }
        }
    }
    
}

//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import FirebaseStorage
import SVProgressHUD

class RegisterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, formTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var generalView: UIView!
    @IBOutlet weak var formItemsTableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var uploadImageButton: UIButton!
    
    
    var buttomViewHeight: CGFloat = 0.0
    var validData: Bool = false
    var dictToSave: [String : String] = [:]
    var imageName: String = ""
    var image_data: UIImage?
    var imageRef : StorageReference = StorageReference()
    
    let userNameKey = "name"
    let phoneKey = "phone"
    let countryKey = "country"
    let cityKey = "city"
    let streetKey = "street"
    let emailKey = "email"
    let passwordKey = "password"
    let vPasswordKey = "vPassword"
    
    var keys: [String] = []
    var formItemsDict: [String: FormItem] = [:]
    
    let userDetailsDB = Database.database().reference().child("userDetails")
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        buttomViewHeight = heightConstraint.constant
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        formItemsTableView.addGestureRecognizer(tapGesture)
        generalView.addGestureRecognizer(tapGesture)
        
        keys = [userNameKey, phoneKey, countryKey, cityKey, streetKey, emailKey, passwordKey, vPasswordKey]
        
        formItemsDict = [
            userNameKey: FormItem(placeholder: "Full Name*", isMandatory: true, isSecure: false),
            phoneKey: FormItem(placeholder: "Phone Number", isMandatory: false, isSecure: false),
            countryKey: FormItem(placeholder: "Country", isMandatory: false, isSecure: false),
            cityKey: FormItem(placeholder: "City", isMandatory: false, isSecure: false),
            streetKey: FormItem(placeholder: "Street", isMandatory: false, isSecure: false),
            emailKey: FormItem(placeholder: "Email*", isMandatory: true, isSecure: false),
            passwordKey: FormItem(placeholder: "Password*", isMandatory: true, isSecure: true),
            vPasswordKey: FormItem(placeholder: "Confirm Password*", isMandatory: true, isSecure: true)
        ]

        formItemsTableView.delegate = self
        formItemsTableView.dataSource = self
        formItemsTableView.register(UINib(nibName: "FormItemTableViewCell", bundle: nil), forCellReuseIdentifier: "FormItemTableViewCell")
        
        fileNameLabel.text = ""
        formItemsTableView.reloadData()
        
        for (_ , item) in formItemsDict {
            item.clearItemValue()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        moveViewDown()

    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = Float(keyboardRectangle.height)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = self.buttomViewHeight + CGFloat(keyboardHeight)
            self.view.layoutIfNeeded()
        })
    }

    @objc func tableViewTapped() {
        print("tableViewTapped")
        moveViewDown()
    }
    
    func textFieldValueChanged(value: String, key: String) {
        print("textFieldValueChanged")
        print("key: \(key) value: \(value)")
        formItemsDict[key]?.value = value
        checkValidValue(key: key)
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        print("textFieldDidEndEditing")

    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        formItemsTableView.reloadData()
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formItemsDict.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormItemTableViewCell", for: indexPath) as! FormItemTableViewCell
        if let item = formItemsDict[keys[indexPath.row]] {
            cell.initCell(item, keys[indexPath.row])
            item.indexPath = indexPath
            print(cell.key)
        }
        
        cell.delegate = self
        return cell
    }
    
    @IBAction func registerPressed(_ sender: AnyObject) {

        validData = true
        
        for key in keys {
            checkValidValue(key: key)
        }
        
        formItemsTableView.reloadData()
        
        if validData {
            if formItemsDict[passwordKey]?.value == formItemsDict[vPasswordKey]?.value {
                changeUserInteraction(isEnable: false)
                SVProgressHUD.show()
                Auth.auth().createUser(withEmail: (formItemsDict[emailKey]?.value)!, password: (formItemsDict[passwordKey]?.value)!) {
                    (user, error) in
                    if error != nil {
                        self.moveViewDown()
                        let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        SVProgressHUD.dismiss()
                        self.changeUserInteraction(isEnable: true)
                    }
                    else {
                        //Success
                        for (key, item) in self.formItemsDict {
                            self.dictToSave[key] = item.value
                        }
                        self.saveDetails()
                    }
                    self.moveViewDown()
                    self.fileNameLabel.text = ""
                }
            }
            else {
                formItemsDict[vPasswordKey]?.errorMessage = "Confirm password is not equal to password"
                formItemsTableView.reloadData()
            }
        }
    }
    
    func changeUserInteraction(isEnable: Bool) {
        navigationController?.navigationBar.isUserInteractionEnabled = isEnable
        formItemsTableView.isUserInteractionEnabled = isEnable
        registerButton.isUserInteractionEnabled = isEnable
        uploadImageButton.isUserInteractionEnabled = isEnable
    }
    
    func moveViewDown() {
        formItemsTableView.endEditing(true)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = self.buttomViewHeight
            self.view.layoutIfNeeded()
        })
        
        formItemsTableView.reloadData()
        
    }
    
    func checkValidValue(key: String) {
        
        let item = formItemsDict[key]
    
        item?.checkValidity()
        
        if key == emailKey {
            item?.checkEmail()
        }
            
        else if key == passwordKey {
            item?.checkPassword()
        }
        
        if !(item?.isValid)! {
            validData = false
        }
        
        print("self.isValid \(item?.isValid)")
        print("self.errorMessage \(item?.errorMessage)")

//        for (_ , item) in formItemsDict {
//
//            item.checkValidity()
//            if !item.isValid {
//                 validData = false
//            }
//        }
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate;
        myPickerController.sourceType =  UIImagePickerControllerSourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        print("imagePickerController1")
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM HH:mm"
        let dateNow = formatter.string(from: Date())
        imageName = "profileImage-\(dateNow)"
        image_data = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        imageRef = Storage.storage().reference().child("images/\(imageName).png")
        self.fileNameLabel.text = self.imageName
        self.uploadImageButton.setTitle("Change Picture", for: .normal)
        print("imagePickerController2")
    }
    
    func saveDetails() {
        print("saveImage")
        if image_data != nil {
            if let imageData = UIImageJPEGRepresentation(image_data!, 0.1) {
                imageRef.putData(imageData, metadata: nil) {
                    (metadata, error) in
                    if error != nil {
                        print(error!)
                        print("error1")
                    }
                    else {
                        self.imageRef.downloadURL {
                            url, error in
                            guard error == nil else {return}
                            guard let urlString = url?.absoluteString else {return}
                            print(self.dictToSave)
                            self.dictToSave["imageURL"] = urlString
                            
                            self.saveDetailsAndGoToChat()
                        }
                    }
                }
            }
        }
        else {
            self.saveDetailsAndGoToChat()
        }
    }
    
    func saveDetailsAndGoToChat()
    {
        self.userDetailsDB.childByAutoId().setValue(self.dictToSave) {
            (error, reference) in
            if error != nil {
                print(error!)
            }
            else {
                print("Details saved successfully!")
                self.performSegue(withIdentifier: "goToChat", sender: self)
                for (_ , item) in self.formItemsDict {
                    
                    item.value = ""
                }
            }
            SVProgressHUD.dismiss()
            self.changeUserInteraction(isEnable: true)
        }
    }
}


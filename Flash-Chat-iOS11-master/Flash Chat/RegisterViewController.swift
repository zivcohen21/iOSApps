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
    var registerViewModal = RegisterViewModel()
  
    override func viewDidLoad() {
        super.viewDidLoad()
       
        buttomViewHeight = heightConstraint.constant
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        formItemsTableView.addGestureRecognizer(tapGesture)
        generalView.addGestureRecognizer(tapGesture)

        registerViewModal.initData()
        
        formItemsTableView.delegate = self
        formItemsTableView.dataSource = self
        registerViewModal.delegate = self
        
        formItemsTableView.register(UINib(nibName: "FormItemTableViewCell", bundle: nil), forCellReuseIdentifier: "FormItemTableViewCell")
        
        fileNameLabel.text = ""
        formItemsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
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
        registerViewModal.formItemsDict[key]?.value = value
        registerViewModal.checkValidValue(key: key)
    }
    
    func textFieldEndEditing(value: String, key: String) {
        print("textFieldEndEditing: \(registerViewModal.formItemsDict[key]?.errorMessage)")
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registerViewModal.formItemsDict.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormItemTableViewCell", for: indexPath) as! FormItemTableViewCell
        if let item = registerViewModal.formItemsDict[registerViewModal.keys[indexPath.row]] {
            cell.initCell(item, registerViewModal.keys[indexPath.row])
            item.indexPath = indexPath
            print(cell.key)
        }
        
        cell.delegate = self
        return cell
    }
    
    func moveViewDown() {
        formItemsTableView.endEditing(true)
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = self.buttomViewHeight
            self.view.layoutIfNeeded()
        })
        formItemsTableView.reloadData()
    }
    
    @IBAction func registerPressed(_ sender: AnyObject) {

        registerViewModal.validData()
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate;
        myPickerController.sourceType =  UIImagePickerControllerSourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        registerViewModelUploadPic(registerViewModal.saveImage(info))
    }

}

extension RegisterViewController: RegisterViewModelDelegate {
    
    func registerViewModelGoTo(destination: String) {
        self.performSegue(withIdentifier: destination, sender: self)
    }
    
    
    func registerViewModelUploadPic(_ imageName: String) {
        
        self.dismiss(animated: true, completion: nil)
        self.fileNameLabel.text = imageName
        self.uploadImageButton.setTitle("Change Picture", for: .normal)
    }
    
    func registerViewModelChangeUserInteraction(isEnable: Bool) {
        
        navigationController?.navigationBar.isUserInteractionEnabled = isEnable
        formItemsTableView.isUserInteractionEnabled = isEnable
        registerButton.isUserInteractionEnabled = isEnable
        uploadImageButton.isUserInteractionEnabled = isEnable
    }
    
    func registerViewModelAfterRegisterPressed() {
        moveViewDown()
        self.fileNameLabel.text = ""
    }
    
    func registerViewModelUserDidntSaved(_ error: Error) {
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        SVProgressHUD.dismiss()
        registerViewModelChangeUserInteraction(isEnable: true)
    }
}

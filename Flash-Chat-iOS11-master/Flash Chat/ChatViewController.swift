//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import FirebaseStorage
import SVProgressHUD

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    var messageFieldViewHeight: CGFloat = 0.0
    
    @IBOutlet weak var textFieldView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageFieldViewHeight = textFieldView.frame.size.height
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO: Register your MessageCell.xib file here:
        
        messageTableView.register(UINib(nibName: "MyMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "myMessageTableViewCell")
        messageTableView.register(UINib(nibName: "CustomMessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email {

            let cell = tableView.dequeueReusableCell(withIdentifier: "myMessageTableViewCell", for: indexPath) as! MyMessageTableViewCell
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender
            cell.messageDate.text = messageArray[indexPath.row].messageDate
            cell.avatarImageView.image = getImage(messageArray[indexPath.row].sender)

            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()

            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
            
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender
            cell.messageDate.text = messageArray[indexPath.row].messageDate
            cell.avatarImageView.image = getImage(messageArray[indexPath.row].sender)
            
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
            
            return cell
        }
        

    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageArray.count 
    }
    
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        })
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }

    
    func getImage(_ sender: String) -> UIImage {
        
        var image = UIImage(named: "egg")
        
        let userDetails = Database.database().reference().child("userDetails")
        
        userDetails.observe(.value) {
            (snapshot) in

            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            for (_ , value) in snapshotValue {
                let valueDict = value as! Dictionary<String, String>
                if valueDict["email"] == sender {
                    let imageURL = valueDict["imageURL"]
                    let storageRef = Storage.storage().reference(forURL: imageURL as! String)
                    storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error)
                        } else {
                            if let imageData = data {
                                image = UIImage(data: imageData)
                            }
                        }
                    }
                }
            }
        }
        
        return image!
    }
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        

    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        
       
    }

    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = Float(keyboardRectangle.height)

        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = CGFloat(keyboardHeight) + self.messageFieldViewHeight
            self.view.layoutIfNeeded()
        })
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        //messageTextfield.isEnabled = false
        saveMessage(messageTextfield.text!, isImage: false)
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        
        var sender = ""
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) {
            (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            let text = snapshotValue["MessageBody"] as! String?
            sender = (snapshotValue["Sender"] as! String?)!
            let messageDate = snapshotValue["Date"] as! String?
//            let isImage = snapshotValue["isImage"] as! Bool
//            if isImage {
//
//                let imageMessage = ImageMessage()
//                imageMessage.sender = sender
//                imageMessage.messageDate = messageDate!
//                imageMessage.imageToSend = URL(string: text!)
//                self.messageArray.append(imageMessage)
//            }
//            else {
                let message = Message()
                message.messageBody = text!
                message.sender = sender
                message.messageDate = messageDate!
                self.messageArray.append(message)
            //}
            self.configureTableView()
            
            self.messageTableView.reloadData()
        }
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("error, there was a problem signing out.")
        }
        
    }
    
    
    @IBAction func uploadImageButton(_ sender: Any) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        myPickerController.sourceType =  UIImagePickerControllerSourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM HH:mm"
        let dateNow = formatter.string(from: Date())
        let imageName = "profileImage-\(dateNow)"
        let image_data = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        changeUserInteraction(isEnable: false)
        SVProgressHUD.show()
        let imageRef = Storage.storage().reference().child("images/\(imageName))")
        if let imageData = UIImageJPEGRepresentation(image_data!, 0.6) {
            imageRef.putData(imageData, metadata: nil) {
                (metadata, error) in
                if error != nil {
                    print(error)
                    return
                }
                else {
                    imageRef.downloadURL {
                        url, error in
                        guard error == nil else {return}
                        guard let urlString = url?.absoluteString else {return}
                        
                        self.saveMessage(urlString, isImage: true)
                        
                        self.messageTextfield.text = imageName
                        SVProgressHUD.dismiss()
                        self.changeUserInteraction(isEnable: true)
                    }
                }
            }
        }
        
    }
    
    func changeUserInteraction(isEnable: Bool) {
        navigationController?.navigationBar.isUserInteractionEnabled = isEnable
        sendButton.isUserInteractionEnabled = isEnable
        messageTextfield.isUserInteractionEnabled = isEnable
    }
    
    func saveMessage(_ messageText: String, isImage: Bool) {
        let messagesDB = Database.database().reference().child("Messages")
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM HH:mm"
        let dateNow = formatter.string(from: Date())
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageText, "Date": dateNow]//, "isImage": isImage] as [String : Any]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                print(error!)
            }
            else {
                print("Message saved successfully!")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    

}

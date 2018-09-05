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
    var allUsers : [String : User] = [String : User]()
    
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
        messageTableView.register(UINib(nibName: "MyImageMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "myImageMessageTableViewCell")
        messageTableView.register(UINib(nibName: "ImageMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "imageMessageTableViewCell")
        
        getAllProfileImages()
        
        configureTableView()
        
        messageTableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = MessageCell()
        
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email {
            if messageArray[indexPath.row].isImage {
                print(messageArray[indexPath.row].messageDate)
                cell = tableView.dequeueReusableCell(withIdentifier: "myImageMessageTableViewCell", for: indexPath) as! MyImageMessageTableViewCell
                (cell as! MyImageMessageTableViewCell).sendImageView.image = (messageArray[indexPath.row] as! ImageMessage).imageToSend
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "myMessageTableViewCell", for: indexPath) as! MyMessageTableViewCell
                cell.messageBody.text = messageArray[indexPath.row].messageBody
           }
            
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        else {
            if messageArray[indexPath.row].isImage {
                cell = tableView.dequeueReusableCell(withIdentifier: "imageMessageTableViewCell", for: indexPath) as! ImageMessageTableViewCell
                (cell as! ImageMessageTableViewCell).sendImageView.image = (messageArray[indexPath.row] as! ImageMessage).imageToSend
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
                cell.messageBody.text = messageArray[indexPath.row].messageBody
           }
            
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.messageDate.text = messageArray[indexPath.row].messageDate
        cell.avatarImageView.image = messageArray[indexPath.row].profileImage
        
        return cell
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

    func getAllProfileImages() {
        
        var image = UIImage(named: "egg")
        
        let userDetails = Database.database().reference().child("userDetails")
        
        userDetails.observeSingleEvent(of: .value, with: {
            
            (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            var index = 0
            for (_ , value) in snapshotValue {
                
                let valueDict = value as! Dictionary<String, String>
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
                    
                    let user = User()
                    user.email = valueDict["email"]!
                    user.country = valueDict["country"]!
                    user.city = valueDict["city"]!
                    user.street = valueDict["street"]!
                    user.phone = valueDict["phone"]!
                    user.profileImage = image
                    self.allUsers[user.email] = user
                    index += 1
                    if index == snapshotValue.count {
                        self.retrieveMessages()
                    }
                }
            }
            
            
        })
    }
    
//    func getImage(_ sender: String, completion: @escaping (_ results: UIImage)->()) {
//
//        var image = UIImage(named: "egg")
//
//        let userDetails = Database.database().reference().child("userDetails")
//
//        userDetails.observe(.value) {
//            (snapshot) in
//
//            let snapshotValue = snapshot.value as! Dictionary<String, Any>
//            for (_ , value) in snapshotValue {
//                let valueDict = value as! Dictionary<String, String>
//                if valueDict["email"] == sender {
//                    let imageURL = valueDict["imageURL"]
//                    let storageRef = Storage.storage().reference(forURL: imageURL as! String)
//                    storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//                        if let error = error {
//                            print(error)
//                        } else {
//                            if let imageData = data {
//                                image = UIImage(data: imageData)
//                                completion(image!)
//                                print("1 \(image!.size)")
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        print("2 \(image!.size)")
//    }


    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = Float(keyboardRectangle.height)

        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = CGFloat(keyboardHeight) + self.messageFieldViewHeight
            print(self.heightConstraint.constant)
            self.view.layoutIfNeeded()
        })
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        //messageTextfield.isEnabled = false
        if messageTextfield.text != "" {
            saveMessage(messageTextfield.text!, isImage: false)
        }
        
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        print("retrieveMessages")
        var sender = ""
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if snapshot.exists() {
                let snapshotValue = snapshot.value as! Dictionary<String, Any>
                for(_ ,value) in snapshotValue {
                    print("snapshotValue")
                    let valueDict = value as! Dictionary<String, Any>
                    let text = valueDict["MessageBody"] as! String?
                    sender = (valueDict["Sender"] as! String?)!
                    let messageDate = valueDict["Date"] as! String?
                    let isImage = valueDict["isImage"] as! Bool
                    
                    self.initMessage(text!, isImage, messageDate!, sender)
                    self.messageTableView.reloadData()
                }
            }
            
        })

        self.configureTableView()
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
        if let imageData = UIImageJPEGRepresentation(image_data!, 0.1) {
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
        
        let sender = Auth.auth().currentUser?.email
        let messagesDB = Database.database().reference().child("Messages")
        let dateNow = getDateNow()
        let messageDictionary = ["Sender": sender, "MessageBody": messageText, "Date": dateNow, "isImage": isImage] as [String : Any]
        

        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                print(error!)
            }
            else {
                
                self.initMessage(messageText, isImage, dateNow, sender!)
                
                self.messageTableView.reloadData()
                print("Message saved successfully!")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToProfilePage",
            let destination = segue.destination as? ProfileViewController,
            let index = messageTableView.indexPathForSelectedRow?.row
        {
            destination.userName = messageArray[index].sender
        }
    }
    
    func initMessage(_ messageText: String, _ isImage: Bool, _ dateNow: String, _ sender: String) {
        
        print("initMessage")
        if isImage
        {
            let storageRef = Storage.storage().reference(forURL: messageText)
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                } else {
                    if let imageData = data {
                        
                        let imageMessage = ImageMessage(sender: sender, messageBody: "", messageDate: dateNow, isImage: isImage, profileImage: (self.allUsers[sender]?.profileImage)!, imageToSend: UIImage(data: imageData)!)
                        self.messageArray.append(imageMessage)
                        print("3 \(imageMessage.imageToSend!.size)")
                        self.messageTableView.reloadData()
                    }
                }
            }
            //            let imageMessage = ImageMessage(sender: sender!, messageBody: messageText, messageDate: dateNow, isImage: isImage, profileImage: (self.allUsers[sender]?.profileImage)!, )
        }
        else {
            let message = Message(sender: sender, messageBody: messageText, messageDate: dateNow, isImage: isImage, profileImage: (self.allUsers[sender]?.profileImage)!)
            self.messageArray.append(message)
        }
        
    }
    
    func getDateNow() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM HH:mm"
        return formatter.string(from: Date())
    }

}

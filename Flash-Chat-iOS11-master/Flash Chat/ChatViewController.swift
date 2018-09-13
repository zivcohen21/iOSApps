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
import SDWebImage

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    // Declare instance variables here
    var chatViewModel = ChatViewModel()
    var datesUtils = DatesUtils()
    var messageFieldViewHeight: CGFloat = 0.0
    var messagePressed: Message?
    //var tapGestureRecognizer = UITapGestureRecognizer()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!

    
    @IBOutlet weak var textFieldView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageFieldViewHeight = textFieldView.frame.size.height

        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        chatViewModel.delegate = self
        messageTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        //tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        
        
        messageTableView.register(UINib(nibName: "MyMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "myMessageTableViewCell")
        messageTableView.register(UINib(nibName: "CustomMessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        messageTableView.register(UINib(nibName: "MyImageMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "myImageMessageTableViewCell")
        messageTableView.register(UINib(nibName: "ImageMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "imageMessageTableViewCell")
        
        messageTableView.separatorStyle = .none
        
        chatViewModel.getAllProfileImages()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = MessageCell()
        let currentMessage = chatViewModel.messageArray[indexPath.row]
        
        if currentMessage.email == Auth.auth().currentUser?.email {
            
            if currentMessage.isImage {
                print(currentMessage.messageDate)
                cell = tableView.dequeueReusableCell(withIdentifier: "myImageMessageTableViewCell", for: indexPath) as! MyImageMessageTableViewCell
                (cell as! MyImageMessageTableViewCell).sendImageView.sd_setImage(with: URL(string: currentMessage.messageBody), placeholderImage: UIImage(named: "placeholder.png"))
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "myMessageTableViewCell", for: indexPath) as! MyMessageTableViewCell
                cell.messageBody.text = currentMessage.messageBody
           }
            
            cell.profilePicButton.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        else {
            if currentMessage.isImage {
                cell = tableView.dequeueReusableCell(withIdentifier: "imageMessageTableViewCell", for: indexPath) as! ImageMessageTableViewCell
                (cell as! ImageMessageTableViewCell).sendImageView.sd_setImage(with: URL(string: currentMessage.messageBody), placeholderImage: UIImage(named: "placeholder.png"))
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
                cell.messageBody.text = currentMessage.messageBody
           }
            
            cell.profilePicButton.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        cell.senderUsername.text = currentMessage.sender
        cell.messageDate.text = datesUtils.getDateAsStringWithoutSec(currentMessage.messageDate)
        let profileImageUrl = currentMessage.profileImage
        if profileImageUrl.count > 0
        {
            cell.profilePicButton.sd_setBackgroundImage(with: URL(string: profileImageUrl), for: .normal)
            cell.profilePicButton.clipsToBounds = true
            cell.profilePicButton.layer.cornerRadius = cell.profilePicButton.frame.size.width / 2
            //cell.avatarImageView.sd_setImage(with: URL(string: profileImageUrl), placeholderImage: UIImage(named: "placeholder.png"))
        }
        else {
            cell.profilePicButton.setImage(UIImage(named: "egg"), for: .normal)
        }
        
        cell.messageIndex = indexPath.row
        cell.profilePicButton.isUserInteractionEnabled = true
        //cell.profilePicButton.addGestureRecognizer(tapGestureRecognizer)
    
        cell.delegate = self
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatViewModel.messageArray.count
    }
    
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
        removeKeyboard()
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }

    @objc func keyboardWillShow(notification: Notification) {
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = Float(keyboardRectangle.height)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.heightConstraint.constant = CGFloat(keyboardHeight) + self.messageFieldViewHeight
            if #available(iOS 11.0, *) {
                self.heightConstraint.constant -= self.view.safeAreaInsets.bottom
            }
            self.view.layoutIfNeeded()
        })
        
        messageTableView.scrollToBottom()
    }
    
//    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
//    {
//        let tappedImage = tapGestureRecognizer.view as! UIImageView
//        self.performSegue(withIdentifier: "goToProfilePage", sender: self)
//
//    }
    
    func removeKeyboard() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = self.messageFieldViewHeight
            self.view.layoutIfNeeded()
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let imageName = "profileImage-\(datesUtils.getDateNow(format: "dd-MM HH:mm"))"
        let image_data = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        changeUserInteraction(isEnable: false)
        SVProgressHUD.show()
        self.removeKeyboard()
        let imageRef = Storage.storage().reference().child("images/\(imageName))")
        if let imageData = UIImageJPEGRepresentation(image_data!, 0.1) {
            imageRef.putData(imageData, metadata: nil) {
                (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                else {
                    imageRef.downloadURL {
                        url, error in
                        guard error == nil else {return}
                        guard let urlString = url?.absoluteString else {return}
                        
                        self.chatViewModel.saveMessage(urlString, isImage: true)
                        
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
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        if messageTextfield.text != "" {
            chatViewModel.saveMessage(messageTextfield.text!, isImage: false)
        }
    }
   
    @IBAction func logOutPressed(_ sender: AnyObject) {

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
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare 1")
        if segue.identifier == "goToProfilePage",
            let destination = segue.destination as? ProfileViewController,
            let currMessage = messagePressed
//            , let index = messageTableView.indexPathForSelectedRow?.row
        {
            //print(destination)
            destination.user = chatViewModel.allUsers[currMessage.email]
            destination.user?.profileImage = currMessage.profileImage
        }
    }
}

extension ChatViewController: ChatViewModelDelegate, MessageCellDelegate{

    internal func chatViewModelMessageRetrieved() {
        
        self.messageTableView.reloadData()
        self.messageTableView.scrollToBottom()
    }
  
    internal func chatViewModelMessageSaved() {
        
        self.messageTableView.reloadData()
        self.messageTableView.scrollToBottom()
        print("Message saved successfully!")
        
        self.messageTextfield.isEnabled = true
        self.sendButton.isEnabled = true
        self.messageTextfield.text = ""
    }
    
    internal func messageCellProfilePressed(_ index: Int) {
        
        print("messageCellProfilePressed")
        messagePressed = chatViewModel.messageArray[index]
        self.performSegue(withIdentifier: "goToProfilePage", sender: self)
    }
}

//
//  ChatViewModel.swift
//  Flash Chat
//
//  Created by matan elimelech on 12/09/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import ChameleonFramework
import FirebaseStorage
import SVProgressHUD
import SDWebImage

protocol ChatViewModelDelegate {
    func chatViewModelMessageSaved()
    func chatViewModelMessageRetrieved()
}

class ChatViewModel {
    
    var messageArray : [Message] = [Message]()
    var allUsers : [String : User] = [String : User]()
    var delegate : ChatViewModelDelegate?
    var datesUtils = DatesUtils()
    
    func getAllProfileImages() {
        
        let userDetails = Database.database().reference().child("userDetails")
        
        userDetails.observeSingleEvent(of: .value, with: {
            
            (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            var index = 0
            for (_ , value) in snapshotValue {
                
                let valueDict = value as! Dictionary<String, String>
                let imageURL = valueDict["imageURL"]
                if imageURL != nil {

                index += 1
                self.saveUser(index, imageURL!, valueDict, snapshotValue)
               
                }
                else {
                    index += 1
                    self.saveUser(index, "", valueDict, snapshotValue)
                }
            }
        })
    }
    
    func saveUser(_ index : Int, _ imageURL : String, _  valueDict : [String : String], _ snapshotValue : Dictionary<String, Any>) {
        
        let user = User()
        user.name = valueDict["name"]!
        user.email = valueDict["email"]!
        user.country = valueDict["country"]!
        user.city = valueDict["city"]!
        user.street = valueDict["street"]!
        user.phone = valueDict["phone"]!
        user.profileImage = imageURL
        self.allUsers[user.email] = user
        
        if index == snapshotValue.count {
            self.retrieveMessages()
        }
    }
    
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if snapshot.exists() {
                let snapshotValue = snapshot.value as! Dictionary<String, Any>
                for(_ ,value) in snapshotValue {
                    let valueDict = value as! Dictionary<String, Any>
                    let text = valueDict["MessageBody"] as! String?
                    let sender = (valueDict["Sender"] as! String?)!
                    let email = (valueDict["Email"] as! String?)!
                    let messageDate = valueDict["Date"] as! String?
                    let isImage = valueDict["IsImage"] as! Bool
                    
                    self.initMessage(text!, isImage, messageDate!, sender, email)
                }
                self.sortMessages()
            }
            self.delegate?.chatViewModelMessageRetrieved()
        })
    }
    
    func initMessage(_ messageText: String, _ isImage: Bool, _ dateNow: String, _ sender: String, _ email: String) {

        let message = Message(sender: sender, email: email, messageBody: messageText, messageDate: dateNow, isImage: isImage, profileImage: (self.allUsers[email]?.profileImage)!)
        self.messageArray.append(message)
    }
    
    func sortMessages() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM HH:mm:ss"
        messageArray = messageArray.sorted(by: { formatter.date(from: $0.messageDate)! <  formatter.date(from: $1.messageDate)!})
    }
    
    func saveMessage(_ messageText: String, isImage: Bool) {
        
        let email = (Auth.auth().currentUser?.email)!
        let sender = allUsers[email]?.name
        let messagesDB = Database.database().reference().child("Messages")
        let dateNow = datesUtils.getDateNow(format: "dd-MM HH:mm:ss")
        let messageDictionary = ["Sender": sender!, "Email": email ,"MessageBody": messageText, "Date": dateNow, "IsImage": isImage] as [String : Any]
        
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                print(error!)
            }
            else {
                
                self.initMessage(messageText, isImage, dateNow, sender!, email)
                
                self.delegate?.chatViewModelMessageSaved()
            }
        }
    }
}


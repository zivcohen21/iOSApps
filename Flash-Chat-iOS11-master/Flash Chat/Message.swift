//
//  Message.swift
//  Flash Chat
//
//  This is the model class that represents the blueprint for a message
import UIKit
import Foundation

class Message {
    
    //TODO: Messages need a messageBody and a sender variable
    var sender : String = ""
    var messageBody : String = ""
    var messageDate: String = ""
    var isImage : Bool = false
    var profileImage : String
    var email : String
    
    init(sender : String, email : String, messageBody : String, messageDate : String, isImage : Bool, profileImage : String) {
        self.sender = sender
        self.email = email
        self.messageBody = messageBody
        self.messageDate = messageDate
        self.isImage = isImage
        self.profileImage = profileImage
    }
}

//
//  MessageCell.swift
//  Flash Chat
//
//  Created by matan elimelech on 02/09/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet var messageBackground: UIView!
    @IBOutlet var senderUsername: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var messageBody: UILabel!
    @IBOutlet var messageDate: UILabel!
}


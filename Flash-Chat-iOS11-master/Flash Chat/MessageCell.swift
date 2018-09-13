//
//  MessageCell.swift
//  Flash Chat
//
//  Created by matan elimelech on 02/09/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit

protocol MessageCellDelegate {
    func messageCellProfilePressed(_ index: Int)
}

class MessageCell: UITableViewCell {
    
    var delegate : MessageCellDelegate?
    var messageIndex: Int = -1
    
    @IBOutlet var messageBackground: UIView!
    @IBOutlet var senderUsername: UILabel!
    @IBOutlet var profilePicButton: UIButton!
    @IBOutlet var messageBody: UILabel!
    @IBOutlet var messageDate: UILabel!
    
    @IBAction func profilePressed(_ sender: Any) {
        print("profilePressed \(self.messageIndex)")
        self.delegate?.messageCellProfilePressed(self.messageIndex)
    }
}


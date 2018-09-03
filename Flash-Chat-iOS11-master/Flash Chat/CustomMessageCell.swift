//
//  CustomMessageCell.swift
//  Flash Chat
//
//  Created by Angela Yu on 30/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit

class CustomMessageCell: MessageCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code goes here
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
    }

}

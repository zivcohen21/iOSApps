//
//  CustomMessageCell.swift
//  Flash Chat
//
//  Created by Angela Yu on 30/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit

class CustomMessageCell: MessageCell {

    //@IBOutlet weak var profileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code goes here
        //avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
//
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
//        avatarImageView.isUserInteractionEnabled = true
//        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }

//    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
//    {
//        let tappedImage = tapGestureRecognizer.view as! UIImageView
//        self.performSegue(withIdentifier: "goToProfilePage", sender: self)
//        
//    }
}

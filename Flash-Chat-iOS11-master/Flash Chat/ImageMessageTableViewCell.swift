//
//  ImageMessageTableViewCell.swift
//  Flash Chat
//
//  Created by matan elimelech on 04/09/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit

class ImageMessageTableViewCell: MessageCell {

    @IBOutlet weak var sendImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

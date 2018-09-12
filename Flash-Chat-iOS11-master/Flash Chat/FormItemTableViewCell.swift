//
//  FormItemTableViewCell.swift
//  Flash Chat
//
//  Created by matan elimelech on 28/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

protocol formTableViewCellDelegate {
    func textFieldValueChanged(value : String, key : String)
    func textFieldEndEditing(value : String, key : String)
}

class FormItemTableViewCell: UITableViewCell, UITextFieldDelegate{
    
    @IBOutlet weak var formItemTextField: SkyFloatingLabelTextField!
    
    
    var key: String = ""
    var item: FormItem!
    
    let green = UIColor(red: 102/255, green: 202/255, blue: 97/255, alpha: 1.0)
    let darkGreyColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
    let overcastBlueColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    var delegate : formTableViewCellDelegate?
    
    func initCell(_ item: FormItem, _ key: String){
        
        formItemTextField.title = item.placeholder
        formItemTextField.placeholder = item.placeholder
        formItemTextField.text = item.value
        formItemTextField.placeholderColor = green
        formItemTextField.tintColor = green // the color of the blinking cursor
        formItemTextField.textColor = green
        formItemTextField.lineColor = green
        formItemTextField.selectedTitleColor = green
        formItemTextField.selectedLineColor = green
        formItemTextField.delegate = self
        formItemTextField.lineHeight = 1.0 // bottom line height in points
        formItemTextField.selectedLineHeight = 2.0
        formItemTextField.isSecureTextEntry = item.isSecure
        
        formItemTextField.errorMessage = item.errorMessage
    
        self.key = key
        self.item = item
    }
    
    @IBAction func editingChangedAction(_ sender: Any) {
        self.delegate?.textFieldValueChanged(value: self.formItemTextField.text!, key: self.key)
        if self.item.isValid {
            formItemTextField.errorMessage = item.errorMessage
        }
    }
    
    @IBAction func editingEndAction(_ sender: Any) {
        formItemTextField.errorMessage = self.item.errorMessage
        //self.delegate?.textFieldEndEditing(value: self.formItemTextField.text!, key: self.key)
    }
    
    func cleanCell() {
        formItemTextField.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
}

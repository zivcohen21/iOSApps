//
//  FormItem.swift
//  Flash Chat
//
//  Created by matan elimelech on 28/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import Foundation

class FormItem {
    
    var value = ""
    var placeholder = ""
    var indexPath: IndexPath?
    var isMandatory = true
    var isValid = true
    var errorMessage: String?
    var isSecure = false
    init(placeholder: String, isMandatory: Bool, isSecure: Bool) {
        
        self.placeholder = placeholder
        self.isMandatory = isMandatory
        self.isSecure = isSecure
    }
    
    func checkValidity() {
        
        if self.isMandatory {
            self.isValid = self.value.isEmpty == false
            
            if !self.isValid {
                self.errorMessage = "Please fill current Field"
            }
            else {
                self.errorMessage = nil
            }
        } else {
            self.isValid = true
            self.errorMessage = nil
        }
    }
    
    func checkPassword() {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[0-9])[A-Za-z\\d$@$#!%*?&]{8,}")
        
        print("range: \(passwordTest.evaluate(with: self.value))")
        
        if self.value.count < 8 {
            print("1")
            self.errorMessage = "Paswword length should be a least 8 characters"
            self.isValid = false
        }
        else if !passwordTest.evaluate(with: self.value) {
            print("2")
            self.errorMessage = "Paswword should contain at least one letter and one number"
            self.isValid = false
        }
        else {
            print("3")
            self.isValid = true
        }
        
    }
    
    func checkEmail() {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        self.isValid = emailTest.evaluate(with: self.value)
        
        if !self.isValid {
            self.errorMessage = "Invalid email address"
        }
        else {
            self.errorMessage = nil
        }

    }

    
    func clearItemValue() {
        self.value = ""
    }
}

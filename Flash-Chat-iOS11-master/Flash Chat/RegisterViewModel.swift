//
//  RegisterViewModel.swift
//  Flash Chat
//
//  Created by matan elimelech on 12/09/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SVProgressHUD

protocol RegisterViewModelDelegate {
    func registerViewModelChangeUserInteraction(isEnable: Bool)
    func registerViewModelUserDidntSaved(_ error: Error)
    func registerViewModelAfterRegisterPressed()
    func registerViewModelUploadPic(_ imageName: String)
    func registerViewModelGoTo(destination: String)
}

class RegisterViewModel {

    var delegate : RegisterViewModelDelegate?
    var isValidData: Bool = false
    var dictToSave: [String : String] = [:]
    var imageName: String = ""
    var image_data: UIImage?
    var imageRef : StorageReference = StorageReference()
    
    let userNameKey = "name"
    let phoneKey = "phone"
    let countryKey = "country"
    let cityKey = "city"
    let streetKey = "street"
    let emailKey = "email"
    let passwordKey = "password"
    let vPasswordKey = "vPassword"
    
    var keys: [String] = []
    var formItemsDict: [String: FormItem] = [:]
    
    let userDetailsDB = Database.database().reference().child("userDetails")
    
    var datesUtils = DatesUtils()
    
    func initData() {
        
        keys = [userNameKey, phoneKey, countryKey, cityKey, streetKey, emailKey, passwordKey, vPasswordKey]
        
        formItemsDict = [
            userNameKey: FormItem(placeholder: "Full Name*", isMandatory: true, isSecure: false),
            phoneKey: FormItem(placeholder: "Phone Number", isMandatory: false, isSecure: false),
            countryKey: FormItem(placeholder: "Country", isMandatory: false, isSecure: false),
            cityKey: FormItem(placeholder: "City", isMandatory: false, isSecure: false),
            streetKey: FormItem(placeholder: "Street", isMandatory: false, isSecure: false),
            emailKey: FormItem(placeholder: "Email*", isMandatory: true, isSecure: false),
            passwordKey: FormItem(placeholder: "Password*", isMandatory: true, isSecure: true),
            vPasswordKey: FormItem(placeholder: "Confirm Password*", isMandatory: true, isSecure: true)
        ]
        
        for (_ , item) in formItemsDict {
            item.clearItemValue()
        }
    }

    func validData() {
        
        isValidData = true
        
        for key in keys {
            checkValidValue(key: key)
        }
        
        if isValidData {
            if formItemsDict[passwordKey]?.value == formItemsDict[vPasswordKey]?.value {
                
                self.delegate?.registerViewModelChangeUserInteraction(isEnable: false)
                
                SVProgressHUD.show()
                Auth.auth().createUser(withEmail: (formItemsDict[emailKey]?.value)!, password: (formItemsDict[passwordKey]?.value)!) {
                    (user, error) in
                    if error != nil {
                        self.delegate?.registerViewModelUserDidntSaved(error!)
                    }
                    else {
                        //Success
                        for (key, item) in self.formItemsDict {
                            self.dictToSave[key] = item.value
                        }
                        self.saveDetails()
                    }
                    
                    self.delegate?.registerViewModelAfterRegisterPressed()
                   
                }
            }
            else {
                formItemsDict[vPasswordKey]?.errorMessage = "Confirm password is not equal to password"
            }
        }
    }
    
    func checkValidValue(key: String) {
        
        let item = formItemsDict[key]
        
        item?.checkValidity()
        
        if key == emailKey {
            item?.checkEmail()
        }
            
        else if key == passwordKey || key == vPasswordKey {
            item?.checkPassword()
        }
        
        if !(item?.isValid)! {
            isValidData = false
        }
    }
    
    func saveImage(_ info : [String : Any] ) -> String {
        
        imageName = "profileImage-\(datesUtils.getDateNow(format: "dd-MM HH:mm"))"
        image_data = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageRef = Storage.storage().reference().child("images/\(imageName).png")

        return imageName
    }
    
    func saveDetailsAndGoToChat()
    {
        self.userDetailsDB.childByAutoId().setValue(self.dictToSave) {
            (error, reference) in
            if error != nil {
                print(error!)
            }
            else {
                print("Details saved successfully!")
                self.delegate?.registerViewModelGoTo(destination: "goToChat")
                
                for (_ , item) in self.formItemsDict {
                    
                    item.value = ""
                }
            }
            SVProgressHUD.dismiss()
            self.delegate?.registerViewModelChangeUserInteraction(isEnable: true)
        }
    }
    
    func saveDetails() {
        print("saveImage")
        if image_data != nil {
            if let imageData = UIImageJPEGRepresentation(image_data!, 0.1) {
                imageRef.putData(imageData, metadata: nil) {
                    (metadata, error) in
                    if error != nil {
                        print(error!)
                        print("error1")
                    }
                    else {
                        self.imageRef.downloadURL {
                            url, error in
                            guard error == nil else {return}
                            guard let urlString = url?.absoluteString else {return}
                            print(self.dictToSave)
                            self.dictToSave["imageURL"] = urlString
                            
                            self.saveDetailsAndGoToChat()
                        }
                    }
                }
            }
        }
        else {
            self.saveDetailsAndGoToChat()
        }
    }
}

//
//  ProfileViewModel.swift
//  Flash Chat
//
//  Created by matan elimelech on 12/09/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class ProfileViewModel {
    
    let userNameKey = "name"
    let phoneKey = "phone"
    let countryKey = "country"
    let cityKey = "city"
    let streetKey = "street"
    
    var dictToSave: [String : String] = [:]
    var keys: [String] = []
    var detailsItemsDict: [String: FormItem] = [:]
    let userDetailsDB = Database.database().reference().child("userDetails")
    let currentUser = Auth.auth().currentUser
    
    func initData(_ user: User) {
        
        keys = [userNameKey, phoneKey, countryKey, cityKey, streetKey]
        
        detailsItemsDict = [
            userNameKey: FormItem(placeholder: "Full Name", isMandatory: true, isSecure: false),
            phoneKey: FormItem(placeholder: "Phone Number", isMandatory: false, isSecure: false),
            countryKey: FormItem(placeholder: "Country", isMandatory: false, isSecure: false),
            cityKey: FormItem(placeholder: "City", isMandatory: false, isSecure: false),
            streetKey: FormItem(placeholder: "Street", isMandatory: false, isSecure: false)
        ]
        
        detailsItemsDict[userNameKey]?.value = user.name
        detailsItemsDict[phoneKey]?.value = user.phone
        detailsItemsDict[countryKey]?.value = user.country
        detailsItemsDict[cityKey]?.value = user.city
        detailsItemsDict[streetKey]?.value = user.street
        
    }
    
    func validDateAndSave(_ user: User) {
        print("validDateAndSave1")
        if detailsItemsDict[userNameKey]?.value.isEmpty == false {
            print("validDateAndSave2")
            for (key, item) in detailsItemsDict {
                dictToSave[key] = item.value
            }
            userDetailsDB.queryOrdered(byChild: "email").queryEqual(toValue: currentUser?.email).observeSingleEvent(of: .value, with: { (snapshot) in
                if let result = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in result  {
                        self.userDetailsDB.child(child.key).updateChildValues(self.dictToSave)
                        print(child.key)
                        
                        user.name = self.dictToSave[self.userNameKey]!
                        user.phone = self.dictToSave[self.phoneKey]!
                        user.country = self.dictToSave[self.countryKey]!
                        user.city = self.dictToSave[self.cityKey]!
                        user.street = self.dictToSave[self.streetKey]!
                
                    }
                }
                
            })
        }
    }
    
}

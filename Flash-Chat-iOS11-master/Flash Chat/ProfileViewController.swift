//
//  ProfileViewController.swift
//  Flash Chat
//
//  Created by matan elimelech on 03/09/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var profileViewModel = ProfileViewModel()
    var user: User?
    var buttomViewHeight: CGFloat = 0.0
    
    @IBOutlet var generalView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userDetailsTableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user?.email != Auth.auth().currentUser?.email {
            saveChangesButton.alpha = 0.0
            saveChangesButton.isUserInteractionEnabled = false
        }
        
        buttomViewHeight = heightConstraint.constant
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        userDetailsTableView.addGestureRecognizer(tapGesture)
        generalView.addGestureRecognizer(tapGesture)
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        profileImageView.addGestureRecognizer(tapImage)
    
        
        profileViewModel.initData(user!)
        
        userDetailsTableView.delegate = self
        userDetailsTableView.dataSource = self
        
        userDetailsTableView.register(UINib(nibName: "FormItemTableViewCell", bundle: nil), forCellReuseIdentifier: "FormItemTableViewCell")
        
        userDetailsTableView.reloadData()
        
        profileImageView.sd_setImage(with: URL(string: (user?.profileImage)!), placeholderImage: UIImage(named: "placeholder.png"))
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        moveViewDown()
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileViewModel.detailsItemsDict.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormItemTableViewCell", for: indexPath) as! FormItemTableViewCell
        if let item = profileViewModel.detailsItemsDict[profileViewModel.keys[indexPath.row]] {
            if user?.email != Auth.auth().currentUser?.email {
                cell.formItemTextField.isUserInteractionEnabled = false
            }
            cell.initCell(item, profileViewModel.keys[indexPath.row])
            item.indexPath = indexPath
            print(cell.key)
            
            
        }
        
        return cell
    }
    
    @objc func tableViewTapped() {
        moveViewDown()
    }
    
    @objc func imageViewTapped() {
//        profileImageView.frame = UIScreen.main.bounds
//        profileImageView.backgroundColor = .black
//        profileImageView.contentMode = .center
//        profileImageView.clipsToBounds = true
//        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
//        //self.view.addSubview(profileImageView)
//        //self.navigationController?.isNavigationBarHidden = true
//        //self.tabBarController?.tabBar.isHidden = true
    }
    
    func moveViewDown() {
        userDetailsTableView.endEditing(true)
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = self.buttomViewHeight + self.bottomHeight.constant + self.saveButtonHeight.constant
            self.view.layoutIfNeeded()
        })
        //userDetailsTableView.reloadData()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = Float(keyboardRectangle.height)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = CGFloat(keyboardHeight)
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func SaveChangesPressed(_ sender: Any) {
        
        profileViewModel.validDateAndSave()
    }
    
    
}

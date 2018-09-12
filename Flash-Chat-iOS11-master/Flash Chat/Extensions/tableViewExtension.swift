//
//  tableViewExtension.swift
//  Flash Chat
//
//  Created by matan elimelech on 12/09/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit

extension UITableView {
    
    func scrollToBottom(){
        
        DispatchQueue.main.async {
            let rows = self.numberOfRows(inSection:  self.numberOfSections - 1) - 1
            if rows > 0 {
                let indexPath = IndexPath(
                    row: rows,
                    section: self.numberOfSections - 1)
                self.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}

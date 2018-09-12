    //
//  DatesUtils.swift
//  Flash Chat
//
//  Created by matan elimelech on 12/09/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import Foundation
    class DatesUtils {
        
        func getDateNow(format: String) -> String {
            
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.string(from: Date())
        }
        
        func convertDateToString(_ date: Date, format: String) -> String {
            
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.string(from: date)
        }
        
        func convertStringToDate (_ dateAsString: String, format: String) -> Date {
            
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.date(from: dateAsString)!
        }
        
        func getDateAsStringWithoutSec(_ theDate: String) -> String {
            
            return convertDateToString(convertStringToDate(theDate, format: "dd-MM HH:mm:ss"), format: "dd-MM HH:mm")
        }
    }

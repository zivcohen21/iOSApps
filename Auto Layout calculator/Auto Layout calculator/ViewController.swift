//
//  ViewController.swift
//  Auto Layout calculator
//
//  Created by matan elimelech on 19/08/2018.
//  Copyright © 2018 Moveo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var screenLabel: UILabel!
    var firstNum : Double = 0
    var secondNum : Double = 0
    var sign : Int = 0
    var numAfterDot : Int = 0
    var isFirstNum : Bool = true
    var afterDot : Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        screenLabel.text = "\(firstNum)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonAction(_ sender: Any) {
        
        let tagNum : Int = (sender as! UIButton).tag
        
        if tagNum == 10 {
            firstNum = 0
            screenLabel.text = "\(firstNum)"
        }
        // signs Buttons
        else if tagNum >= 13 && tagNum <= 16 {
            isFirstNum = false
            sign = tagNum
            secondNum = 0
        }
        // equalButton
        else if tagNum == 17 {
            
            switch sign {
            case 13:
                firstNum /= secondNum
            case 14:
                firstNum *= secondNum
            case 15:
                firstNum -= secondNum
            case 16:
                firstNum += secondNum
            default:
                firstNum = 0
            }
            screenLabel.text = "\(firstNum)"
            
            isFirstNum = true
        }
        // digitsButtons
        else if tagNum <= 9 {
            
            if isFirstNum {
        
                firstNum = firstNum * 10 + Double(tagNum)
                screenLabel.text = "\(firstNum)"
            }
            else {
                secondNum = secondNum * 10 + Double(tagNum)
                screenLabel.text = "\(secondNum)"
            }
            
        }
    }
}


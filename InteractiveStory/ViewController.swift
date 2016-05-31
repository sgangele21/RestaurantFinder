//
//  ViewController.swift
//  InteractiveStory
//
//  Created by Sahil Gangele on 5/29/16.
//  Copyright © 2016 Sahil Gangele. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    enum Error: ErrorType {
        case NoName
    }

    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        do {
            if segue.identifier == "startAdventure" {
                if let pageController = segue.destinationViewController as? PageController {
                    pageController.page = Adventure.story("Sahil")
                }
            if let name = nameTextField.text {
                if name == "" {
                    throw Error.NoName
                    }
                }
            }
            
        }catch Error.NoName {
            let alert = UIAlertController(title: "Name Not Entered", message: "You must enter a name", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
        }catch let error {
            fatalError("\(error)")
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let userInfoDict = notification.userInfo, keyboardFrameValue = userInfoDict[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.CGRectValue()
            
            UIView.animateWithDuration(10.0) {
                self.textFieldBottomConstraint.constant = keyboardFrame.height + 10
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let userInfoDict = notification.userInfo, keyboardFrameValue = userInfoDict[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.CGRectValue()
            
            UIView.animateWithDuration(1.0) {
                self.textFieldBottomConstraint.constant = 40.0
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }



}


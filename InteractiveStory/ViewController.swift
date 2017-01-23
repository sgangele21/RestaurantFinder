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
    
    enum TextFieldError: Error {
        case noName
    }

    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        do {
            if segue.identifier == "startAdventure" {
                if let pageController = segue.destination as? PageController {
                    pageController.page = Adventure.story("Sahil")
                }
            if let name = nameTextField.text {
                if name == "" {
                    throw TextFieldError.noName
                    }
                }
            }
            
        }catch TextFieldError.noName {
            let alert = UIAlertController(title: "Name Not Entered", message: "You must enter a name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        }catch let error {
            fatalError("\(error)")
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let userInfoDict = notification.userInfo, let keyboardFrameValue = userInfoDict[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.cgRectValue
            
            UIView.animate(withDuration: 10.0, animations: {
                self.textFieldBottomConstraint.constant = keyboardFrame.height + 10
                self.view.layoutIfNeeded()
            }) 
            
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let userInfoDict = notification.userInfo, let keyboardFrameValue = userInfoDict[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.cgRectValue
            
            UIView.animate(withDuration: 1.0, animations: {
                self.textFieldBottomConstraint.constant = 40.0
                self.view.layoutIfNeeded()
            }) 
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }



}


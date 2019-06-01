//
//  LoginVC.swift
//  On the map
//
//  Created by Mawhiba Al-Jishi on 23/09/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit

class LoginVC: UIViewController {
  
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    
    @IBAction func login(_ sender: Any){
        updateUI(processing: true)
        let userEmail = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        let userPassword = passwordTextField.text?.trimmingCharacters(in: .whitespaces)
        
        if (userEmail!.isEmpty) || (userPassword!.isEmpty)  {
            self.alert(title: "Empty Field", message: "Plese enter your email and psswprd")
            self.updateUI(processing: false)
            return
        }
        
        UdacityAPI.postSessionForLogin(with: userEmail!, password: userPassword!) { (data, error) in
            if error != nil {
                self.alert(title: "Error", message: error?.localizedDescription)
                self.updateUI(processing: false)
                return
            } else {
                if let data = data,
                    let errorMessage = data["error"] as? String {
                    self.updateUI(processing: false)
                    self.alert(title: "Error Login", message: errorMessage)
                } else {
                    DispatchQueue.main.async {
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        self.updateUI(processing: false)
                        self.performSegue(withIdentifier: "tabBarController", sender: self)
                    }
                }
            }
        }
    }
    
    func updateUI(processing: Bool){
        DispatchQueue.main.async {
            self.emailTextField.isUserInteractionEnabled = !processing
            self.passwordTextField.isUserInteractionEnabled = !processing
            self.loginButton.isEnabled = !processing
            
        }
    }
}



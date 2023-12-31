//
//  ForgotPasswordViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 8/1/23.
//

import PostgresClientKit
import UIKit

class ForgotPasswordViewController: UIViewController {
    
    let model = DatabaseManager.shared.connectToDatabase()
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordButton: UIButton!
    
    var userInformation = [Model.User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        usernameField.text = ""
        passwordField.text = ""

        passwordButton.isUserInteractionEnabled = false
        
        view.backgroundColor = .link
    }
    
    @IBAction func passwordFieldFilled() {
        if passwordField.text != "" {
            passwordButton.isUserInteractionEnabled = true
        } else {
            passwordButton.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func passwordButtonPressed() {
        view.endEditing(true)
        
        let username = usernameField.text?.trimmingCharacters(in: [" "]) ?? ""
        let password = passwordField.text?.trimmingCharacters(in: [" "]) ?? ""
        
        model.updateUserPassword(username, password:password) { result in
            do {
                self.userInformation = try result.get()
                Postgres.logger.fine("Length of user list: " + String(self.userInformation.count))
                if self.userInformation.count < 1 {
                    
                } else if password == self.userInformation.first?.password {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
                            
                        // This is to get the SceneDelegate object from your view controller
                        // then call the change root view controller function to change to main tab bar
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                    }
                } else {
                }
            } catch {
                // Better error handling goes here...
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
}

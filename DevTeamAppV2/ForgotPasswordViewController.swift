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
    @IBOutlet var errorView: UITextView!
    
    @IBOutlet var usernameButton: UIButton!
    @IBOutlet var passwordButton: UIButton!
    
    var username: String!
    var userInformation = [Model.User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        usernameField.text = ""
        passwordField.text = ""
        passwordField.isUserInteractionEnabled = false
        errorView.text = ""
        errorView.isUserInteractionEnabled = false
        
        usernameButton.isUserInteractionEnabled = false
        passwordButton.isUserInteractionEnabled = false
        
        view.backgroundColor = .link
    }
    
    @IBAction func usernameFieldFilled() {
        if usernameField.text != "" {
            usernameButton.isUserInteractionEnabled = true
        } else {
            usernameButton.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func usernameButtonPressed() {
        view.endEditing(true)
        
        let uname = usernameField.text?.trimmingCharacters(in: [" "]) ?? ""
        
        model.userInformation(uname) { result in
            do {
                self.userInformation = try result.get()
                Postgres.logger.fine("Length of user list: " + String(self.userInformation.count))
                if self.userInformation.count < 1 {
                    self.errorView.text = "That username doesn't exist"
                }
                if uname == self.userInformation.first?.username {
                    self.errorView.text = "That username exists"
                    self.passwordField.isUserInteractionEnabled = true
                    self.username = uname
                }
            } catch {
                // Better error handling goes here...
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
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
        
        let password = passwordField.text?.trimmingCharacters(in: [" "]) ?? ""
        
        model.updateUserPassword(self.username, password:password) { result in
            do {
                self.userInformation = try result.get()
                Postgres.logger.fine("Length of user list: " + String(self.userInformation.count))
                if self.userInformation.count < 1 {
                    self.errorView.text = "The password update failed: username was invalid"
                } else if password == self.userInformation.first?.password {
                    self.errorView.text = "Password updated successfully"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
                            
                        // This is to get the SceneDelegate object from your view controller
                        // then call the change root view controller function to change to main tab bar
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                    }
                } else {
                    self.errorView.text = "Password update failed"
                }
            } catch {
                // Better error handling goes here...
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
}

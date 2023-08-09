//
//  ViewController.swift
//  DevTeamApp
//
//  Created by Andrew Sauerbrei on 7/26/23.
//

import PostgresClientKit
import UIKit

class ViewController: UIViewController {
    
    // Injected by SceneDelegate.
    var model: Model!
    
    let currentUser = CurrentUser.shared
    
    let defaultPassword = "password"
    
    // The text field for the city name.
    @IBOutlet var usernameField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var errorView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.text = ""
        passwordField.text = ""
        errorView.text = ""
        errorView.isEditable = false
    }

    // Called when the "Login" button is tapped.
    @IBAction func loginUser() {
        view.endEditing(true)
        let username = usernameField.text?.trimmingCharacters(in: [" "]) ?? ""
        let password = passwordField.text?.trimmingCharacters(in: [" "]) ?? ""
        
        // Catch is called if there is a connectiong failure
        // To check if there is a user found, have to check length of userInformation
        // Different types of issues will require their own checks
        // Figure out how to display error messages -> put an empty text field in the view
            // in order to display error messages
        model.userInformation(username) { result in
            do {
                self.userInformation = try result.get()
                Postgres.logger.fine("Length of user list: " + String(self.userInformation.count))
                if self.userInformation.count < 1 {
                    self.errorView.text = "That username does not exist."
                }
                
                if username == self.userInformation.first?.username && password != self.userInformation.first?.password {
                    Postgres.logger.fine("Password is incorrect")
                    self.errorView.text = "That password is incorrect for the given username."
                }
                if username == self.userInformation.first?.username && password == self.userInformation.first?.password {
                    Postgres.logger.fine("Login Successful")
                    self.errorView.text = "Login successful"
                    
                    self.currentUser.setCurrentUserName(name: self.userInformation.first?.name ?? " ")
                    
                    if password == self.defaultPassword {
                        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "forgotPasswordView") as? ForgotPasswordViewController
                        else {
                            print("Button pressed failed")
                            return
                        }
                        
                        self.present(vc, animated:true)
                    }
                    
                    guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "dashboardView") as? DashboardViewController
                    else {
                        print("Button pressed failed")
                        return
                    }
                    self.present(vc, animated:true)
                    
                } else {
                    Postgres.logger.fine("Login Failed")
                    self.errorView.text = "Login failed for unknown reason"
                }
            } catch {
                // Better error handling goes here...
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    
    //
    // MARK: UITableViewDataSource
    //

    var userInformation = [Model.User]()
    
    @IBAction func forgotPasswordButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "forgotPasswordView") as? ForgotPasswordViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
}

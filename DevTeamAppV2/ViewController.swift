//
//  ViewController.swift
//  DevTeamApp
//
//  Created by Andrew Sauerbrei on 7/26/23.
//

import PostgresClientKit
import UIKit
import AppCenter
import AppCenterCrashes


class ViewController: UIViewController {
    
    // Injected by SceneDelegate.
    let model = DatabaseManager.shared.connectToDatabase()
    
    let currentUser = CurrentUser.shared
    
    let defaultPassword = "password"
    
    // The text field for the city name.
    @IBOutlet var usernameField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var errorView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        usernameField.text = ""
        passwordField.text = ""
        errorView.text = ""
        errorView.isEditable = false
        
        AppCenter.start(withAppSecret: "ef64b400-cb63-42db-9065-30f3414d9e65", services:[
            Crashes.self
          ])
    }

    // Called when the "Login" button is tapped.
    @IBAction func loginUser() {
        view.endEditing(true)
        self.errorView.text = ""
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
                if username == self.userInformation.first?.username && password == self.userInformation.first?.password {
                    Postgres.logger.fine("Login Successful")
                    self.errorView.text = "Login successful"
                    
                    self.currentUser.setCurrentUserName(name: self.userInformation.first?.name ?? " ")
                    self.currentUser.setCurrentUserRole(role: self.userInformation.first?.role ?? " ")
                    self.currentUser.setCurrentUserID(id: self.userInformation.first?.id ?? 0)
                    
                    if password == self.defaultPassword {
                        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "forgotPasswordView") as? ForgotPasswordViewController
                        else {
                            print("Button pressed failed")
                            return
                        }
                        
                        self.present(vc, animated: true)
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
                            
                        // This is to get the SceneDelegate object from your view controller
                        // then call the change root view controller function to change to main tab bar
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                    }
                    
                } else {
                    Postgres.logger.fine("Login Failed")
                    self.errorView.text = "Password is Incorrect"
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

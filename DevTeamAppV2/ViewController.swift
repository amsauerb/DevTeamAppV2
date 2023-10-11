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
    let deviceManager = DeviceManager.shared
    
    let defaultPassword = "password"
    
    // The text field for the city name.
    @IBOutlet var usernameField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var logoImageView: UIImageView!
    
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var forgotPasswordButton: UIButton!
    
    @IBOutlet var line7ImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
//        usernameField.text = ""
//        passwordField.text = ""
        
        AppCenter.start(withAppSecret: "ef64b400-cb63-42db-9065-30f3414d9e65", services:[
            Crashes.self
          ])
        
        loadPrettyViews()
    }
    
    func loadPrettyViews() {
        logoImageView.layer.opacity = 1


        usernameField.layer.cornerRadius = 10
        usernameField.layer.masksToBounds =  true
        usernameField.layer.borderColor = UIColor.black.cgColor
        usernameField.layer.borderWidth =  1
        usernameField.backgroundColor = UIColor.daisy
        usernameField.layer.opacity = 1
        usernameField.textColor = UIColor.slate
        usernameField.font = UIFont.textStyle7
        usernameField.textAlignment = .left
        usernameField.borderStyle = .none

        usernameField.placeholder = NSLocalizedString("Username", comment: "")


        passwordField.layer.cornerRadius = 10
        passwordField.layer.masksToBounds =  true
        passwordField.backgroundColor = UIColor.salt5
        passwordField.layer.opacity = 1
        passwordField.textColor = UIColor.slate
        passwordField.font = UIFont.textStyle7
        passwordField.textAlignment = .left
        passwordField.isSecureTextEntry = true

        passwordField.placeholder = NSLocalizedString("password", comment: "")


        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds =  true
        loginButton.layer.borderColor = UIColor.cerulean.cgColor
        loginButton.layer.borderWidth =  1
        loginButton.backgroundColor = UIColor.sapphire
        loginButton.layer.opacity = 1
        loginButton.setTitleColor(UIColor.daisy, for: .normal)
        loginButton.titleLabel?.font = UIFont.textStyle16
        loginButton.contentHorizontalAlignment = .leading

        loginButton.setTitle(NSLocalizedString("Login", comment: ""),for: .normal)


        forgotPasswordButton.setTitleColor(UIColor.cloud3, for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.textStyle7
        forgotPasswordButton.contentHorizontalAlignment = .leading

        forgotPasswordButton.setTitle(NSLocalizedString("Forgot my Password", comment: ""),for: .normal)


        line7ImageView.layer.opacity = 1
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
                    //
                }
                if username == self.userInformation.first?.username && password == self.userInformation.first?.password {
                    Postgres.logger.fine("Login Successful")
                    
                    self.currentUser.setCurrentUserName(name: self.userInformation.first?.name ?? " ")
                    self.currentUser.setCurrentUserRole(role: self.userInformation.first?.role ?? " ")
                    self.currentUser.setCurrentUserID(id: self.userInformation.first?.id ?? 0)
                    
                    self.model.setUserDevices(username, devices: self.deviceManager.getCurrentDeviceIdentifer()) { result in
                        do {
                            self.userInformation = try result.get()
                            
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
                        } catch {
                            Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                        }
                    }
                    
                } else {
                    Postgres.logger.fine("Login Failed")
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

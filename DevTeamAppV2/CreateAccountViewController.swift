//
//  CreateAccountViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/30/23.
//

import PostgresClientKit
import UIKit

class CreateAccountViewController: UIViewController {
    
    let model = DatabaseManager.shared.connectToDatabase()
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var errorView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.text = ""
        passwordField.text = ""
        nameField.text = ""
        errorView.text = ""
        errorView.isEditable = false
        
        view.backgroundColor = .link
    }
    
    @IBAction func createAccountButtonPressed() {
        view.endEditing(true)
        
        let username = usernameField.text?.trimmingCharacters(in: [" "]) ?? ""
        let password = passwordField.text?.trimmingCharacters(in: [" "]) ?? ""
        let name = nameField.text?.trimmingCharacters(in: [" "]) ?? ""
        
        model.createUser(username, password: password, name: name) { result in
            do {
                self.userInformation = try result.get()
                Postgres.logger.fine("Length of user list: " + String(self.userInformation.count))
                if self.userInformation.count < 1 {
                    self.errorView.text = "The account wasn't created correctly"
                } else if username == self.userInformation.first?.username && password == self.userInformation.first?.password {
                    self.errorView.text = "The account was created successfully"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.dismiss(animated: true, completion: nil)
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
    
    var userInformation = [Model.User]()
}

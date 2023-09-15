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
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var errorView: UITextView!
    @IBOutlet var roleMenu: UIButton!
    @IBOutlet var userMenu: UIButton!
    @IBOutlet var updateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        emailField.text = ""
        nameField.text = ""
        errorView.text = ""
        errorView.isEditable = false
        
        setRoleButton(selected: "")
        setUserButton()
        
        updateButton.isUserInteractionEnabled = false
    }
    
    func setRoleButton(selected: String) {
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
        if selected == "Admin" {
            roleMenu.menu = UIMenu(children: [
                UIAction(title: "Admin", state: .on,  handler: optionClosure),
                UIAction(title : "Developer", handler: optionClosure)])
        } else {
            roleMenu.menu = UIMenu(children: [
                UIAction(title: "Admin", handler: optionClosure),
                UIAction(title : "Developer", state: .on, handler: optionClosure)])
        }
        
        
        roleMenu.showsMenuAsPrimaryAction = true
        roleMenu.changesSelectionAsPrimaryAction = true
    }
    
    func setUserButton() {
        let optionClosure = {(action: UIAction) in
            self.displayUserInfo()}
        
        model.getAllUsers() { result in
            do {
                self.userInformation = try result.get()
                
                var children: [UIMenuElement] = []
                
                let a = UIAction(title: "Current Users", state: .on, handler: optionClosure)
                children.append(a)
                
                for user in self.userInformation {
                    let action = UIAction(title: user.name, handler: optionClosure)
                    children.append(action)
                }
                self.userMenu.menu = UIMenu(children: children)
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
        
        userMenu.showsMenuAsPrimaryAction = true
        userMenu.changesSelectionAsPrimaryAction = true
    }
    
    @IBAction func displayUserInfo() {
        let name = userMenu.menu?.selectedElements.first?.title ?? ""
        
        if name != "" {
            model.userByName(name) { result in
                do {
                    self.userInformation = try result.get()
                    self.emailField.text = self.userInformation.first?.email
                    self.nameField.text = self.userInformation.first?.name
                    self.setRoleButton(selected: self.userInformation.first?.role ?? "")
                    self.updateButton.isUserInteractionEnabled = true
                } catch {
                    Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                }
            }
        }
    }
    
    @IBAction func createAccountButtonPressed() {
        view.endEditing(true)
        
        let email = emailField.text?.trimmingCharacters(in: [" "]) ?? ""
        let name = nameField.text?.trimmingCharacters(in: [" "]) ?? ""
        let delimiter = "@"
        let emailTokens = email.components(separatedBy: delimiter)
        let username = emailTokens[0]
        
        let role = roleMenu.menu?.selectedElements.first?.title ?? "Developer"
        
        model.createUser(username, password: "password", name: name, email: email, role: role) { result in
            do {
                self.userInformation = try result.get()
                Postgres.logger.fine("Length of user list: " + String(self.userInformation.count))
                if self.userInformation.count < 1 {
                    self.errorView.text = "The account wasn't created correctly"
                } else if username == self.userInformation.first?.username && email == self.userInformation.first?.email {
                    self.errorView.text = "The account was created successfully"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.emailField.text = ""
                        self.nameField.text = ""
                        self.errorView.text = ""
                        self.setUserButton()
                    }
                } else {
                    Postgres.logger.fine("Account Creation Failed")
                }
            } catch {
                // Better error handling goes here...
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func updateButtonPressed() {
        let email = emailField.text?.trimmingCharacters(in: [" "]) ?? ""
        let name = nameField.text?.trimmingCharacters(in: [" "]) ?? ""
        let username = self.userInformation.first?.username ?? ""
        
        let role = roleMenu.menu?.selectedElements.first?.title ?? "Developer"
        
        model.updateUserInformation(username, name: name, email: email, role: role) { result in
            do {
                self.userInformation = try result.get()
                let filtered = self.userInformation.filter {$0.username == username}
                if !filtered.isEmpty {
                    self.errorView.text = "User information updated successfully."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.emailField.text = ""
                        self.nameField.text = ""
                        self.errorView.text = ""
                        self.setUserButton()
                        self.updateButton.isUserInteractionEnabled = false
                    }
                } else {
                    self.errorView.text = "That user does not exist, update unsuccessful"
                }
                
                
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func deleteUserButtonPressed() {
        let email = emailField.text?.trimmingCharacters(in: [" "]) ?? ""
        let delimiter = "@"
        let emailTokens = email.components(separatedBy: delimiter)
        let username = emailTokens[0]
        
        model.deleteUser(username) { result in
            do {
                self.userInformation = try result.get()
                if self.userInformation.first?.username == username {
                    self.errorView.text = "User deletion successful"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.emailField.text = ""
                        self.nameField.text = ""
                        self.errorView.text = ""
                        self.setUserButton()
                    }
                }
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func closeButtonPressed() {
        self.dismiss(animated: true)
    }
    
    var userInformation = [Model.User]()
}

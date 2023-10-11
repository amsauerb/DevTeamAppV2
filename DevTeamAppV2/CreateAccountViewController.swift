//
//  CreateAccountViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/30/23.
//

import PostgresClientKit
import UIKit
import MessageUI

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
    
    func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            errorView.text = "Email sending is not enabled."
            return
        }
        
        var sendTo = [String]()
        sendTo.append(emailField.text!)
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(sendTo)
        composer.setSubject("DevApp Account Setup")
        composer.setMessageBody("Hello " + nameField.text! + ",\n\nWelcome to the Mr. Beast Video Development App. This email is meant to connect you with the app distributer and get you started with how it works.\n\nFirst thing to do is go to https://appcenter.ms on the iOS device you want to use and create an account with the same email that this message was sent to. Once you have finished making the account and arrived on the account dashboard screen, click the Get Started button. This will send you to a screen to add your device. Press the Add Device button, then press Allow on the prompt. This will show a dialog box that directs you to accept a profile that the phone has downloaded. If you go to the settings app, you will see a new prompt at the top that says Profile Downloaded. Clicking this opens the Install Profile screen. Once there, press Install in the top right, enter your passcode, and then press Install on the bottom prompt. You'll then be redirected back to your browser, and you'll see your device listed.\n\n At this point, there should be an email in your account inviting you to the app Organization from App Center. The organization is called Video Development App. Accept this invitation or click the Go To App button in the email. This will open a new tab in your browser of choice showing that you are a part of the organization, putting you on the Overview screen. You will see a download looking button on the right side. Pressing this will redirect you a new page where you will be able to download the latest build to your phone. Clicking Install creates a popup that will let you install the app to your device. Go to the homescreen, and you will see that the app DevAppV2 is now downloaded.", isHTML: false)
        present(composer, animated: true)
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
                    self.showMailComposer()
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

extension CreateAccountViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            print("Cancelled")
        case .failed:
            print("Failed to send")
        case .saved:
            print("Saved")
        case .sent:
            print("Email Sent")
        @unknown default:
            break
        }
        
        controller.dismiss(animated: true)
    }
}

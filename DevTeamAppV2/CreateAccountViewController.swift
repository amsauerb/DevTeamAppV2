//
//  CreateAccountViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/30/23.
//

import PostgresClientKit
import UIKit
import MessageUI

class CreateAccountViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let model = DatabaseManager.shared.connectToDatabase()
    let currentUser = CurrentUser.shared
    
    var userInformation = [Model.User]()
    var updateUserName : [String] = []
    var updateUserEmail : [String] = []
    var updateUserRole : [String] = []
    
    @IBOutlet var welcomeField: UILabel!
    @IBOutlet var userThumbnail: UIImageView!
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var roleMenu: UIButton!
    @IBOutlet var newUserThumbnail: UIImageView!
    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var taskButton: UIButton!
    @IBOutlet var videoButton: UIButton!
    @IBOutlet var userButton: UIButton!
    @IBOutlet var dashboardButton: UIButton!
    @IBOutlet var addUserButton: UIButton!
    
    @IBOutlet var container: UIView!
    
    @IBOutlet var userManagementCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        emailField.text = ""
        nameField.text = ""
        
        userManagementCollection.delegate = self
        userManagementCollection.dataSource = self
        
        welcomeField.text = currentUser.getCurrentUserName() + "!"
        
        loadPrettyViews()
        setRoleButton()
        
        model.getAllUsers() { result in
            do {
                self.userInformation = try result.get()
                self.userInformation = self.userInformation.filter {$0.name != self.currentUser.getCurrentUserName()}
                self.updateUserName = [String] (repeating: "", count: self.userInformation.count)
                self.updateUserEmail = [String] (repeating: "", count: self.userInformation.count)
                self.updateUserRole = [String] (repeating: "", count: self.userInformation.count)
                self.userManagementCollection.reloadData()
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    func loadPrettyViews() {
        self.view.backgroundColor = UIColor.daisy
        
        welcomeField.layer.opacity = 1
        welcomeField.textColor = UIColor.black
        welcomeField.numberOfLines = 0
        welcomeField.font = UIFont.textStyle2
        welcomeField.textAlignment = .left
        welcomeField.text = currentUser.getCurrentUserName()
        
        taskButton.layer.cornerRadius = 7
        taskButton.layer.masksToBounds =  true
        taskButton.backgroundColor = UIColor.salt2
        taskButton.layer.opacity = 1
        taskButton.setTitleColor(UIColor.black, for: .normal)
        taskButton.titleLabel?.font = UIFont.textStyle9
        taskButton.contentHorizontalAlignment = .leading
        
        videoButton.layer.cornerRadius = 7
        videoButton.layer.masksToBounds =  true
        videoButton.backgroundColor = UIColor.salt2
        videoButton.layer.opacity = 1
        videoButton.setTitleColor(UIColor.black, for: .normal)
        videoButton.titleLabel?.font = UIFont.textStyle9
        videoButton.contentHorizontalAlignment = .leading
        
        userButton.layer.cornerRadius = 7
        userButton.layer.masksToBounds =  true
        userButton.backgroundColor = UIColor.black
        userButton.layer.opacity = 1
        userButton.setTitleColor(UIColor.daisy, for: .normal)
        userButton.titleLabel?.font = UIFont.textStyle9
        userButton.contentHorizontalAlignment = .leading
        
        addUserButton.layer.cornerRadius = 7
        addUserButton.layer.masksToBounds =  true
        addUserButton.layer.borderColor = UIColor.sapphire.cgColor
        addUserButton.layer.borderWidth =  2
        addUserButton.layer.opacity = 1
        addUserButton.setTitleColor(UIColor.sapphire, for: .normal)
        addUserButton.titleLabel?.font = UIFont.textStyle9
        addUserButton.contentHorizontalAlignment = .leading
        
//        dashboardButton.layer.cornerRadius = 7
//        dashboardButton.layer.masksToBounds =  true
//        dashboardButton.layer.borderColor = UIColor.sapphire.cgColor
//        dashboardButton.layer.borderWidth =  2
//        dashboardButton.layer.opacity = 1
//        dashboardButton.setTitleColor(UIColor.sapphire, for: .normal)
//        dashboardButton.titleLabel?.font = UIFont.textStyle9
//        dashboardButton.contentHorizontalAlignment = .leading
        
//        container.layer.cornerRadius = 10
//        container.layer.masksToBounds =  true
        container.backgroundColor = UIColor.daisy
        container.layer.opacity = 1

        container.layer.masksToBounds = false
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.7
        container.layer.shadowOffset = CGSize(width: 3, height: 3)
        container.layer.shadowRadius = 3
        
        userThumbnail.layer.cornerRadius = 10
        userThumbnail.layer.borderWidth = 1
        userThumbnail.layer.borderColor = UIColor.black.cgColor
        
        newUserThumbnail.layer.cornerRadius = 10
        newUserThumbnail.layer.borderWidth = 1
        newUserThumbnail.layer.borderColor = UIColor.black.cgColor
    }
    
    func setRoleButton() {
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
        roleMenu.menu = UIMenu(children: [
            UIAction(title: "Role", state: .on, handler: optionClosure),
            UIAction(title: "Admin", handler: optionClosure),
            UIAction(title : "Developer", handler: optionClosure)])
        
        roleMenu.showsMenuAsPrimaryAction = true
        roleMenu.changesSelectionAsPrimaryAction = true
    }
    
    func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
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
                    //
                } else if username == self.userInformation.first?.username && email == self.userInformation.first?.email {
                    self.showMailComposer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.emailField.text = "example@email.com"
                        self.nameField.text = "Name"
                        self.setRoleButton()
                    }
                    
                    self.model.getAllUsers() { result in
                        do {
                            self.userInformation = try result.get()
                            self.userInformation = self.userInformation.filter {$0.name != self.currentUser.getCurrentUserName()}
                            self.userManagementCollection.reloadData()
                            
                            self.updateUserName.removeAll()
                            self.updateUserName = [String] (repeating: "", count: self.userInformation.count)
                            
                            self.updateUserEmail.removeAll()
                            self.updateUserEmail = [String] (repeating: "", count: self.userInformation.count)
                            
                            self.updateUserRole.removeAll()
                            self.updateUserRole = [String] (repeating: "", count: self.userInformation.count)
                        } catch {
                            Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                        }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userInformation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserManagementCell", for: indexPath) as! CustomUserManagementCell
        
        let user = userInformation[indexPath.row]
        
        cell.userName.text = user.name
        cell.userName.tag = indexPath.row
        cell.userName.addTarget(self, action: #selector(self.userNameUpdate), for: .editingChanged)
        
        cell.userEmail.text = user.email
        cell.userEmail.tag = indexPath.row
        cell.userEmail.addTarget(self, action: #selector(self.userEmailUpdate), for: .editingChanged)
        
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
//        let a = { [weak self] (action: UIAction) in self.}
        
        if user.role == "Admin" {
            cell.userRole.menu = UIMenu(children: [
                UIAction(title: "Admin", state: .on,  handler: optionClosure),
                UIAction(title : "Developer", handler: optionClosure)])
        } else {
            cell.userRole.menu = UIMenu(children: [
                UIAction(title: "Admin", handler: optionClosure),
                UIAction(title : "Developer", state: .on, handler: optionClosure)])
        }
        
        cell.userRole.showsMenuAsPrimaryAction = true
        cell.userRole.changesSelectionAsPrimaryAction = true
        cell.userRole.tag = indexPath.row
        cell.userRole.addTarget(self, action: #selector(self.userRoleUpdate), for: .touchUpOutside)
        
        cell.editButton.tag = indexPath.row
        cell.editButton.addTarget(self, action: #selector(self.updateUser), for: .touchUpInside)
        
        cell.viewContainer.layer.masksToBounds = false
        cell.viewContainer.layer.shadowColor = UIColor.black.cgColor
        cell.viewContainer.layer.shadowOpacity = 0.7
        cell.viewContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
        cell.viewContainer.layer.shadowRadius = 3
        
        return cell
    }
    
    func userRoleUpdateTwo(sender: UIButton) {
        let path = IndexPath(row: sender.tag, section: 0)
        updateUserRole[path.row] = sender.menu?.selectedElements.first?.title ?? ""
    }
    
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    @objc func userNameUpdate(sender: UITextField) {
        let path = IndexPath(row: sender.tag, section: 0)
        updateUserName[path.row] = sender.text!
    }
    
    @objc func userEmailUpdate(sender: UITextField) {
        let path = IndexPath(row: sender.tag, section: 0)
        updateUserEmail[path.row] = sender.text!
    }
    
    @objc func userRoleUpdate(sender: UIButton) {
        let path = IndexPath(row: sender.tag, section: 0)
        updateUserRole[path.row] = sender.menu?.selectedElements.first?.title ?? ""
    }
    
    @objc func updateUser(sender: UIButton) {
        let path = IndexPath(row: sender.tag, section: 0)
        let user = userInformation[path.row]
        
        var userName = user.name
        var userEmail = user.email
        var userRole = user.role
        
        if updateUserName[path.row] != "" && updateUserName[path.row] != userName {
            userName = updateUserName[path.row]
        }
        
        if updateUserEmail[path.row] != "" && updateUserEmail[path.row] != userEmail {
            userEmail = updateUserEmail[path.row]
        }
        
        if updateUserRole[path.row] != "" && updateUserRole[path.row] != userRole {
            userRole = updateUserRole[path.row]
        }
        
        model.updateUserInformation(user.username, name: userName, email: userEmail, role: userRole) { result in
            do {
                let res = try result.get()
                if res.count == 1 {
                    self.model.getAllUsers() { result in
                        do {
                            self.userInformation = try result.get()
                            self.userInformation = self.userInformation.filter {$0.name != self.currentUser.getCurrentUserName()}
                            self.userManagementCollection.reloadData()
                            
                            self.updateUserName.removeAll()
                            self.updateUserName = [String] (repeating: "", count: self.userInformation.count)
                            
                            self.updateUserEmail.removeAll()
                            self.updateUserEmail = [String] (repeating: "", count: self.userInformation.count)
                            
                            self.updateUserRole.removeAll()
                            self.updateUserRole = [String] (repeating: "", count: self.userInformation.count)
                        } catch {
                            Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                        }
                    }
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.emailField.text = ""
                        self.nameField.text = ""
                    }
                }
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func dashboardButtonPressed() {
        self.dismiss(animated: true)
    }
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

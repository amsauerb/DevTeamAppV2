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
    
    // The text field for the city name.
    @IBOutlet var usernameField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.text = ""
        passwordField.text = ""
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
                if username == self.userInformation.first?.username && password == self.userInformation.first?.password {
                    Postgres.logger.fine("Login Successful")
                } else {
                    Postgres.logger.fine("Login Failed")
                }
            } catch {
                // Better error handling goes here...
                Postgres.logger.severe("Error getting user information: \(String(describing: error))")
            }
        }
    }
    
    
    //
    // MARK: UITableViewDataSource
    //

    var userInformation = [Model.User]()
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") ??
//            UITableViewCell(style: .subtitle, reuseIdentifier: "UserCell")
//
//        let user = userInformation[indexPath.row]
//        let text = String(describing: user.name)
//        let detailText = "On Team: \(user.team) with role \(user.role)"
//
//        cell.textLabel?.text = text
//        cell.detailTextLabel?.text = detailText
//
//        return cell
//    }
    
    @IBAction func teamButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "teamView") as? TeamViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func upcomingVideoButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "upcomingVideoView") as? UpcomingVideoViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func addVideoButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "addVideoView") as? AddVideoViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func videoReviewButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "videoReviewView") as? VideoReviewViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func videoLibraryButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "videoLibraryView") as? VideoLibraryViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
}

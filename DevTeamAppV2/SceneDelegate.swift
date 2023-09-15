//
//  SceneDelegate.swift
//  DevTeamApp
//
//  Created by Andrew Sauerbrei on 7/26/23.
//

import PostgresClientKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let currentUser = CurrentUser.shared

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        // Set the log level to .fine.  That's too verbose for production, but nice for this example.
        Postgres.logger.level = .fine
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if currentUser.getCurrentUserName() != "" {
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            window?.rootViewController = tabBarController
        } else {
            let loginView = storyboard.instantiateViewController(withIdentifier: "loginView")
            window?.rootViewController = loginView
        }
    }
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        
        // change the root view controller to your specific view controller
        window.rootViewController = vc
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
        // Close any existing connection to the Postgres server.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.model.disconnect()
        }
    }
}

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

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        // Set the log level to .fine.  That's too verbose for production, but nice for this example.
        Postgres.logger.level = .fine
        
        // Inject the model into the view controller.
        if let viewController = window?.rootViewController as? ViewController,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            viewController.model = appDelegate.model
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
        // Close any existing connection to the Postgres server.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.model.disconnect()
        }
    }
}

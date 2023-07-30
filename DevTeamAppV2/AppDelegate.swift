//
//  AppDelegate.swift
//  DevTeamApp
//
//  Created by Andrew Sauerbrei on 7/26/23.
//

import PostgresClientKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // In a real app, the user and password could come from a login page.
    let model = Model(environment: Environment.current, user: "postgres", password: "test123")
}

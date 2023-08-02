//
//  DatabaseManager.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 8/1/23.
//

import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init(){}
    
    func connectToDatabase() -> Model
    {
        let model = Model(environment: Environment.current, user: "postgres", password: "test123")
        return model
    }
}

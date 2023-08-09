//
//  CurrentUser.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 8/5/23.
//

import Foundation

class CurrentUser {
    static let shared = CurrentUser()
    
    private init(){}
    
    private var name: String?
    
    func setCurrentUserName(name: String) {
        self.name = name
    }
    
    func getCurrentUserName() -> String {
        return self.name ?? " "
    }
}

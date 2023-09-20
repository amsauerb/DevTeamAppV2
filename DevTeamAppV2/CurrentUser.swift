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
    
    private var role: String?
    
    private var id: Int?
    
    func setCurrentUserName(name: String) {
        self.name = name
    }
    
    func getCurrentUserName() -> String {
        return self.name ?? ""
    }
    
    func setCurrentUserRole(role: String) {
        self.role = role
    }
    
    func getCurrentUserRole() -> String {
        return self.role ?? ""
    }
    
    func setCurrentUserID(id: Int) {
        self.id = id
    }
    
    func getCurrentUserID() -> Int {
        return self.id ?? 0
    }
}

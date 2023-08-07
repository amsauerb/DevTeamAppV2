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
    
    var name: String?
    
    func getCurrentUserName() -> String {
        return name ?? " "
    }
}

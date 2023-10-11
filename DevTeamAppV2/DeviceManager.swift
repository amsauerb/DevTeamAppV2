//
//  DeviceManager.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 9/28/23.
//

import Foundation

class DeviceManager {
    static let shared = DeviceManager()
    
    private init() {}
    
    private var currentDeviceIdentifier: String?
    
    func setCurrentDeviceIdentifier(id: String) {
        currentDeviceIdentifier = id
    }
    
    func getCurrentDeviceIdentifer() -> String {
        return currentDeviceIdentifier ?? ""
    }
}

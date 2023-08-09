//
//  SelectedVideo.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 8/7/23.
//

import Foundation

class SelectedVideo {
    static let shared = SelectedVideo()
    
    private init(){}
    
    private var title: String?
    
    func setSelectedVideoTitle(title: String) {
        self.title = title
    }
    
    func getSelectedVideoTitle() -> String {
        return self.title ?? " "
    }
}

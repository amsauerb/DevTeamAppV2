//
//  CutomVideoCollectionCell.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 8/24/23.
//

import UIKit
import PostgresClientKit

class CutomVideoCollectionCell: UICollectionViewCell {
    let model = DatabaseManager.shared.connectToDatabase()
    var videoInformation = [Model.Video]()
    
    @IBOutlet var videoCellImage: UIImageView!
    @IBOutlet var videoCellTitle: UILabel!
    @IBOutlet var videoCellDate: UIDatePicker!
    
}

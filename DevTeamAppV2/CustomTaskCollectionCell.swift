//
//  CustomTaskCollectionCell.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 8/31/23.
//

import UIKit

class CustomTaskCollectionCell: UICollectionViewCell {
    @IBOutlet var videoTitle: UILabel!
    @IBOutlet var taskInfo: UILabel!
    @IBOutlet var taskDeadlineDate: UIDatePicker!
    @IBOutlet var taskFinishedSwitch: UISwitch!
}

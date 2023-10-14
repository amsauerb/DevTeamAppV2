//
//  CustomTaskTableCell.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 10/13/23.
//

import UIKit

class CustomTaskTableCell: UITableViewCell {
    @IBOutlet var taskName: UITextField!
    @IBOutlet var taskDescription: UITextView!
    @IBOutlet var assignedLabel: UILabel!
    @IBOutlet var taskDeadline: UIDatePicker!
    @IBOutlet var assignedCollection: UICollectionView!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var container: UIView!
}

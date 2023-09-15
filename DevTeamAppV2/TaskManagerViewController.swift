//
//  TaskManagerViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 9/5/23.
//

import PostgresClientKit
import UIKit

class TaskManagerViewController: UIViewController {
    let model = DatabaseManager.shared.connectToDatabase()
    var userInformation = [Model.User]()
}

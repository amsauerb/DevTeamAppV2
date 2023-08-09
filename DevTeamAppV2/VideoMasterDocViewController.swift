//
//  VideoContentViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 8/5/23.
//

import PostgresClientKit
import UIKit
import Foundation

class VideoMasterDocViewController: UIViewController {
    
    let model = DatabaseManager.shared.connectToDatabase()
    let selectedVideo = SelectedVideo.shared
    
    var videoInformation = [Model.Video]()
    
    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var filmdatePicker: UIDatePicker!
    @IBOutlet var directorLabel: UILabel!
    
    @IBOutlet var frameworkDeadlinePicker: UIDatePicker!
    @IBOutlet var frameworkDaysRemaining: UILabel!
    @IBOutlet var frameworkCompletedSwitch: UISwitch!
    
    @IBOutlet var macroDeadlinePicker: UIDatePicker!
    @IBOutlet var macroDaysRemaining: UILabel!
    @IBOutlet var macroCompletedSwitch: UISwitch!
    
    @IBOutlet var microDeadlinePicker: UIDatePicker!
    @IBOutlet var microDaysRemaining: UILabel!
    @IBOutlet var microCompletedSwitch: UISwitch!
    
    @IBOutlet var polishDeadlinePicker: UIDatePicker!
    @IBOutlet var polishDaysRemaining: UILabel!
    @IBOutlet var polishCompletedSwitch: UISwitch!
    
    @IBOutlet var prepreLabel: UILabel!
    @IBOutlet var directorNotesLabel: UILabel!
    @IBOutlet var productionNotesLabel: UILabel!
    @IBOutlet var constructionNotesLabel: UILabel!
    @IBOutlet var shotListLabel: UILabel!
    
    @IBOutlet var budgetCompleteSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.videoInformation(selectedVideo.getSelectedVideoTitle()){ [self] result in
            do {
                self.videoInformation = try result.get()
                if self.videoInformation.count > 0 {
                    // Get image out of the binary string
                    let dataString = videoInformation.first?.thumbnail.first ?? ""
                    let sliceOne = String(dataString.dropFirst())
                    let sliceTwo = String(sliceOne.dropLast())
                    let thumbnailData = Data(base64Encoded: sliceTwo)
                    if let thumbnailData = thumbnailData {
                        thumbnailView.image = UIImage(data: thumbnailData)
                    }
                    let titleText = videoInformation.first?.title
                    titleLabel.text = titleText
                    
                    let currentDay = Date()
                    let filmdate = self.videoInformation.first?.filmdate.date(in: TimeZone.current)
                    filmdatePicker.date = filmdate ?? currentDay
                    
                    directorLabel.text = self.videoInformation.first?.leaddirector
                    
                    macroDeadlinePicker.date = Calendar.current.date(byAdding: .day, value: -30, to: filmdate ?? currentDay) ?? currentDay
                    microDeadlinePicker.date = Calendar.current.date(byAdding: .day, value: -14, to: filmdate ?? currentDay) ?? currentDay
                    polishDeadlinePicker.date = Calendar.current.date(byAdding: .day, value: 14, to: filmdate ?? currentDay) ?? currentDay
                    
                    if self.videoInformation.first?.productiontype == "Thirty" {
                        frameworkDeadlinePicker.date = Calendar.current.date(byAdding: .day, value: -30, to: filmdate ?? currentDay) ?? currentDay
                    } else if self.videoInformation.first?.productiontype == "Sixty" {
                        frameworkDeadlinePicker.date = Calendar.current.date(byAdding: .day, value: -53, to: filmdate ?? currentDay) ?? currentDay
                    } else {
                        frameworkDeadlinePicker.date = Calendar.current.date(byAdding: .day, value: -76, to: filmdate ?? currentDay) ?? currentDay
                    }
                    
                    if self.videoInformation.first?.currentstage == "Framework" {
                        // Do nothing
                    } else if self.videoInformation.first?.currentstage == "Macro" {
                        frameworkCompletedSwitch.isOn = true
                    } else if self.videoInformation.first?.currentstage == "Micro" {
                        frameworkCompletedSwitch.isOn = true
                        macroCompletedSwitch.isOn = true
                    } else if self.videoInformation.first?.currentstage == "Polish" || self.videoInformation.first?.currentstage == "Filmed" {
                        frameworkCompletedSwitch.isOn = true
                        macroCompletedSwitch.isOn = true
                        microCompletedSwitch.isOn = true
                    } else {
                        frameworkCompletedSwitch.isOn = true
                        macroCompletedSwitch.isOn = true
                        microCompletedSwitch.isOn = true
                        polishCompletedSwitch.isOn = true
                    }
                    
                    // Calculate Days Remaining to Each Deadline
                    frameworkDaysRemaining.text = String(Calendar.current.dateComponents([.day], from: currentDay, to: frameworkDeadlinePicker.date).day ?? 0)
                    macroDaysRemaining.text = String(Calendar.current.dateComponents([.day], from: currentDay, to: macroDeadlinePicker.date).day ?? 0)
                    microDaysRemaining.text = String(Calendar.current.dateComponents([.day], from: currentDay, to: microDeadlinePicker.date).day ?? 0)
                    polishDaysRemaining.text = String(Calendar.current.dateComponents([.day], from: currentDay, to: polishDeadlinePicker.date).day ?? 0)
                    
                    // Put document labels
                    prepreLabel.text = self.videoInformation.first?.prepredoc
                    directorNotesLabel.text = self.videoInformation.first?.directorsnotesdoc
                    productionNotesLabel.text = self.videoInformation.first?.productionnotesdoc
                    shotListLabel.text = self.videoInformation.first?.shotlistdoc
                    constructionNotesLabel.text = self.videoInformation.first?.constructionnotesdoc
                    
                    budgetCompleteSwitch.isOn = self.videoInformation.first?.budgetcomplete ?? false
                    
                } else {
                    Postgres.logger.fine("Didn't select the row")
                    self.dismiss(animated: true)
                }
                titleLabel.text = videoInformation.first?.title
            } catch {
                Postgres.logger.severe("Error getting video information: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func updateButtonPressed() {
        view.endEditing(true)
        
        let title = self.titleLabel.text
        
        let budgetcomplete = self.budgetCompleteSwitch.isOn
        
        var currentStage = videoInformation.first?.currentstage
        
        if self.frameworkCompletedSwitch.isOn {
            currentStage = "Macro"
        }
        
        if self.macroCompletedSwitch.isOn {
            currentStage = "Micro"
        }
        
        if self.microCompletedSwitch.isOn {
            currentStage = "Polish"
        }
        
        if self.polishCompletedSwitch.isOn {
            currentStage = "Posted"
        }
        
        model.updateVideoFromMasterDocs(title ?? "", budgetcomplete: budgetcomplete, currentstage: currentStage ?? "Framework") { result in
            do {
                self.videoInformation = try result.get()
                self.dismiss(animated: true, completion: nil)
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
}

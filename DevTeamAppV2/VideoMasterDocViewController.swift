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
    
    var del: VideoMasterDelegate?
    
    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var filmdatePicker: UIDatePicker!
    @IBOutlet var postdatePicker: UIDatePicker!
    @IBOutlet var directorMenu: UIButton!
    @IBOutlet var producerMenu: UIButton!
    
    @IBOutlet var frameworkDeadlinePicker: UIDatePicker!
    //    @IBOutlet var frameworkDaysRemaining: UILabel!
    @IBOutlet var frameworkCompletedSwitch: UISwitch!
    
    @IBOutlet var macroDeadlinePicker: UIDatePicker!
    //    @IBOutlet var macroDaysRemaining: UILabel!
    @IBOutlet var macroCompletedSwitch: UISwitch!
    
    @IBOutlet var microDeadlinePicker: UIDatePicker!
    //    @IBOutlet var microDaysRemaining: UILabel!
    @IBOutlet var microCompletedSwitch: UISwitch!
    
    @IBOutlet var prepreLabel: UITextView!
    @IBOutlet var directorNotesLabel: UITextView!
    @IBOutlet var productionNotesLabel: UITextView!
    @IBOutlet var constructionNotesLabel: UITextView!
    @IBOutlet var shotListLabel: UITextView!
    
    @IBOutlet var budgetCompleteSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
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
                    titleTextField.text = titleText
                    
                    let currentDay = Date()
                    let filmdate = self.videoInformation.first?.filmdate.date(in: TimeZone.current)
                    filmdatePicker.date = filmdate ?? currentDay
                    
                    let postdate = self.videoInformation.first?.postdate.date(in: TimeZone.current)
                    postdatePicker.date = postdate ?? currentDay
                    
                    let director = self.videoInformation.first?.leaddirector
                    let producer = self.videoInformation.first?.leadproducer
                    
                    setDirectorButton(director ?? " ")
                    setProducerButton(producer ?? " ")
                    
                    macroDeadlinePicker.date = (videoInformation.first?.macrodate.date(in: TimeZone.current))!
                    microDeadlinePicker.date = (videoInformation.first?.microdate.date(in: TimeZone.current))!
                    frameworkDeadlinePicker.date = (videoInformation.first?.frameworkdate.date(in: TimeZone.current))!
                    
                    if self.videoInformation.first?.currentstage == "Framework" {
                        // Do nothing
                    } else if self.videoInformation.first?.currentstage == "Macro" {
                        frameworkCompletedSwitch.isOn = true
                    } else if self.videoInformation.first?.currentstage == "Micro" {
                        frameworkCompletedSwitch.isOn = true
                        macroCompletedSwitch.isOn = true
                    } else {
                        frameworkCompletedSwitch.isOn = true
                        macroCompletedSwitch.isOn = true
                        microCompletedSwitch.isOn = true
                    }
                    
                    // Calculate Days Remaining to Each Deadline
                    //                    frameworkDaysRemaining.text = String(Calendar.current.dateComponents([.day], from: currentDay, to: frameworkDeadlinePicker.date).day ?? 0)
                    //                    macroDaysRemaining.text = String(Calendar.current.dateComponents([.day], from: currentDay, to: macroDeadlinePicker.date).day ?? 0)
                    //                    microDaysRemaining.text = String(Calendar.current.dateComponents([.day], from: currentDay, to: microDeadlinePicker.date).day ?? 0)
                    
                    // Put document labels
                    setHyperlink(label: prepreLabel, labelText: "Prepre Doc", pathText: self.videoInformation.first?.prepredoc ?? "")
                    setHyperlink(label: directorNotesLabel, labelText: "Director's Notes Doc", pathText: self.videoInformation.first?.directorsnotesdoc ?? "")
                    setHyperlink(label: productionNotesLabel, labelText: "Production Notes Doc", pathText: self.videoInformation.first?.productionnotesdoc ?? "")
                    setHyperlink(label: shotListLabel, labelText: "Shot List Doc", pathText: self.videoInformation.first?.shotlistdoc ?? "")
                    setHyperlink(label: constructionNotesLabel, labelText: "Construction Notes Doc", pathText: self.videoInformation.first?.constructionnotesdoc ?? "" )
                    //                    prepreLabel.text = self.videoInformation.first?.prepredoc
                    //                    directorNotesLabel.text = self.videoInformation.first?.directorsnotesdoc
                    //                    productionNotesLabel.text = self.videoInformation.first?.productionnotesdoc
                    //                    shotListLabel.text = self.videoInformation.first?.shotlistdoc
                    //                    constructionNotesLabel.text = self.videoInformation.first?.constructionnotesdoc
                    
                    budgetCompleteSwitch.isOn = self.videoInformation.first?.budgetcomplete ?? false
                    
                } else {
                    Postgres.logger.fine("Didn't select the row")
                    self.dismiss(animated: true)
                }
            } catch {
                Postgres.logger.severe("Error getting video information: \(String(describing: error))")
            }
        }
    }
    
    func setHyperlink(label: UITextView, labelText: String, pathText: String) {
        let hyperlink = NSAttributedString.makeHyperlink(for: pathText, in: labelText, as: labelText)
        label.attributedText = hyperlink
    }
    
    func setDirectorButton(_ director: String) {
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
        if director == "Kyle" {
            directorMenu.menu = UIMenu(children: [
                UIAction(title : "Kyle", state: .on, handler: optionClosure),
                UIAction(title : "Drew", handler: optionClosure),
                UIAction(title : "Sean", handler: optionClosure)])
        } else if director == "Drew" {
            directorMenu.menu = UIMenu(children: [
                UIAction(title : "Kyle", handler: optionClosure),
                UIAction(title : "Drew", state: .on, handler: optionClosure),
                UIAction(title : "Sean", handler: optionClosure)])
        } else {
            directorMenu.menu = UIMenu(children: [
                UIAction(title : "Kyle", handler: optionClosure),
                UIAction(title : "Drew", handler: optionClosure),
                UIAction(title : "Sean", state: .on, handler: optionClosure)])
        }
        
        directorMenu.showsMenuAsPrimaryAction = true
        directorMenu.changesSelectionAsPrimaryAction = true
    }
    
    func setProducerButton(_ producer: String) {
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
        if producer == "Dustin" {
            producerMenu.menu = UIMenu(children: [
                UIAction(title : "Dustin", state: .on, handler: optionClosure),
                UIAction(title : "Will", handler: optionClosure),
                UIAction(title : "Mike", handler: optionClosure),
                UIAction(title : "Rachel", handler: optionClosure),
                UIAction(title: "Locoya", handler: optionClosure)])
        } else if producer == "Will" {
            producerMenu.menu = UIMenu(children: [
                UIAction(title : "Dustin", handler: optionClosure),
                UIAction(title : "Will", state: .on, handler: optionClosure),
                UIAction(title : "Mike", handler: optionClosure),
                UIAction(title : "Rachel", handler: optionClosure),
                UIAction(title: "Locoya", handler: optionClosure)])
        } else if producer == "Mike" {
            producerMenu.menu = UIMenu(children: [
                UIAction(title : "Dustin", handler: optionClosure),
                UIAction(title : "Will", handler: optionClosure),
                UIAction(title : "Mike", state: .on, handler: optionClosure),
                UIAction(title : "Rachel", handler: optionClosure),
                UIAction(title: "Locoya", handler: optionClosure)])
        } else if producer == "Rachel" {
            producerMenu.menu = UIMenu(children: [
                UIAction(title : "Dustin", handler: optionClosure),
                UIAction(title : "Will", handler: optionClosure),
                UIAction(title : "Mike", handler: optionClosure),
                UIAction(title : "Rachel", state: .on, handler: optionClosure),
                UIAction(title: "Locoya", handler: optionClosure)])
        } else {
            producerMenu.menu = UIMenu(children: [
                UIAction(title : "Dustin", handler: optionClosure),
                UIAction(title : "Will", handler: optionClosure),
                UIAction(title : "Mike", handler: optionClosure),
                UIAction(title : "Rachel", handler: optionClosure),
                UIAction(title: "Locoya", state: .on, handler: optionClosure)])
        }
        
        producerMenu.showsMenuAsPrimaryAction = true
        producerMenu.changesSelectionAsPrimaryAction = true
    }
    
    @IBAction func updateButtonPressed() {
        view.endEditing(true)
        
        let title = self.titleTextField.text
        
        let producer = producerMenu.menu?.selectedElements.first?.title ?? ""
        let director = directorMenu.menu?.selectedElements.first?.title ?? ""
        
        let filmdate = PostgresDate(date: filmdatePicker.date, in: TimeZone.current)
        let postdate = PostgresDate(date: postdatePicker.date, in: TimeZone.current)
        
        let macroDeadline = Calendar.current.date(byAdding: .day, value: -30, to: filmdatePicker.date)
        let microDeadline = Calendar.current.date(byAdding: .day, value: -14, to: filmdatePicker.date)
        
        var frameworkDeadline = Date()
        
        if videoInformation.first?.productiontype == "Thirty" {
            frameworkDeadline = Calendar.current.date(byAdding: .day, value: -30, to: filmdatePicker.date)!
        } else if videoInformation.first?.productiontype == "Sixty" {
            frameworkDeadline = Calendar.current.date(byAdding: .day, value: -53, to: filmdatePicker.date)!
        } else {
            frameworkDeadline = Calendar.current.date(byAdding: .day, value: -76, to: filmdatePicker.date)!
        }
        
        let budgetcomplete = self.budgetCompleteSwitch.isOn
        
        var currentStage = videoInformation.first?.currentstage
        
        if self.frameworkCompletedSwitch.isOn {
            currentStage = "Macro"
        }
        
        if self.macroCompletedSwitch.isOn {
            currentStage = "Micro"
        }
        
        if self.microCompletedSwitch.isOn {
            currentStage = "Filmed"
        }
        
        if !self.frameworkCompletedSwitch.isOn && !self.macroCompletedSwitch.isOn && !self.microCompletedSwitch.isOn {
            currentStage = "Framework"
        }
        
        let videoId = videoInformation.first?.id
        
        model.updateVideoFromMasterDocs(videoId ?? 0, title : title ?? " ", budgetcomplete: budgetcomplete, currentstage: currentStage ?? "Framework", director: director , producer: producer , filmdate: filmdate, postdate: postdate, macrodate: (macroDeadline?.postgresDate(in: TimeZone.current))!, microdate: (microDeadline?.postgresDate(in: TimeZone.current))!, frameworkdate: frameworkDeadline.postgresDate(in: TimeZone.current)) { result in
            do {
                self.videoInformation = try result.get()
                self.del?.reloadVideos()
                self.dismiss(animated: true, completion: nil)
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        del?.reloadVideos()
    }
}

protocol VideoMasterDelegate {
    func reloadVideos()
}

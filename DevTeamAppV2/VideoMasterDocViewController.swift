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
    let currentUser = CurrentUser.shared
    
    var videoInformation = [Model.Video]()
    
    var del: VideoMasterDelegate?
    
    var budgetComplete = false
    var frameworkPressed = false
    var macroPressed = false
    var microPressed = false
    var updatedStage = "Framework"
    
    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var filmdatePicker: UIDatePicker!
    @IBOutlet var postdatePicker: UIDatePicker!
    @IBOutlet var directorMenu: UIButton!
    @IBOutlet var producerMenu: UIButton!
    
    @IBOutlet var frameworkDeadlinePicker: UIDatePicker!
    //    @IBOutlet var frameworkDaysRemaining: UILabel!
    @IBOutlet var frameworkCompletedButton: UIButton!
    
    @IBOutlet var macroDeadlinePicker: UIDatePicker!
    //    @IBOutlet var macroDaysRemaining: UILabel!
    @IBOutlet var macroCompletedButton: UIButton!
    
    @IBOutlet var microDeadlinePicker: UIDatePicker!
    //    @IBOutlet var microDaysRemaining: UILabel!
    @IBOutlet var microCompletedButton: UIButton!
    
    @IBOutlet var prepreLabel: UITextView!
    @IBOutlet var directorNotesLabel: UITextView!
    @IBOutlet var productionNotesLabel: UITextView!
    @IBOutlet var constructionNotesLabel: UITextView!
    @IBOutlet var shotListLabel: UITextView!
    
    @IBOutlet var budgetCompletedButton: UIButton!
    
    @IBOutlet var userThumbnail: UIImageView!
    @IBOutlet var welcomeField: UILabel!
    @IBOutlet var updateButton: UIButton!
    
    @IBOutlet var frameworkContainer: UIView!
    @IBOutlet var macroContainer: UIView!
    @IBOutlet var microContainer: UIView!
    @IBOutlet var budgetContainer: UIView!
    @IBOutlet var prepreContainer: UIView!
    @IBOutlet var directorContainer: UIView!
    @IBOutlet var productionContainer: UIView!
    @IBOutlet var shotListContainer: UIView!
    @IBOutlet var constructionContainer: UIView!
    
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
                    titleLabel.text = titleText
                    
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
                    
                    let origImage = UIImage(named: "frame3")
                    let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                    
                    if self.videoInformation.first?.currentstage == "Framework" {
                        frameworkCompletedButton.setImage(tintedImage, for: .normal)
                        frameworkCompletedButton.tintColor = .red
                        macroCompletedButton.setImage(tintedImage, for: .normal)
                        macroCompletedButton.tintColor = .red
                        microCompletedButton.setImage(tintedImage, for: .normal)
                        microCompletedButton.tintColor = .red
                    } else if self.videoInformation.first?.currentstage == "Macro" {
                        self.frameworkPressed = true
                        frameworkCompletedButton.setImage(UIImage(named: "frame3"), for: .normal)
                        macroCompletedButton.setImage(tintedImage, for: .normal)
                        macroCompletedButton.tintColor = .red
                        microCompletedButton.setImage(tintedImage, for: .normal)
                        microCompletedButton.tintColor = .red
                    } else if self.videoInformation.first?.currentstage == "Micro" {
                        self.frameworkPressed = true
                        self.macroPressed = true
                        frameworkCompletedButton.setImage(UIImage(named: "frame3"), for: .normal)
                        macroCompletedButton.setImage(UIImage(named: "frame3"), for: .normal)
                        microCompletedButton.setImage(tintedImage, for: .normal)
                        microCompletedButton.tintColor = .red
                    } else {
                        self.frameworkPressed = true
                        self.macroPressed = true
                        self.microPressed = true
                        frameworkCompletedButton.setImage(UIImage(named: "frame3"), for: .normal)
                        macroCompletedButton.setImage(UIImage(named: "frame3"), for: .normal)
                        microCompletedButton.setImage(UIImage(named: "frame3"), for: .normal)
                    }
                    
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
                    
                    if self.videoInformation.first?.budgetcomplete == true {
                        budgetComplete = true
                        self.budgetCompletedButton.setImage(UIImage(named: "frame3"), for: .normal)
                    } else {
                        self.budgetCompletedButton.setImage(tintedImage, for: .normal)
                        self.budgetCompletedButton.tintColor = .red
                    }
                    
                } else {
                    Postgres.logger.fine("Didn't select the row")
                    self.dismiss(animated: true)
                }
            } catch {
                Postgres.logger.severe("Error getting video information: \(String(describing: error))")
            }
        }
        
        loadPrettyViews()
    }
    
    func loadPrettyViews() {
        self.view.backgroundColor = UIColor.daisy
        
        welcomeField.layer.opacity = 1
        welcomeField.textColor = UIColor.black
        welcomeField.numberOfLines = 0
        welcomeField.font = UIFont.textStyle2
        welcomeField.textAlignment = .left
        welcomeField.text = currentUser.getCurrentUserName()
        
        userThumbnail.layer.cornerRadius = 10
        userThumbnail.layer.borderWidth = 1
        userThumbnail.layer.borderColor = UIColor.black.cgColor
        
        updateButton.layer.cornerRadius = 7
        updateButton.layer.masksToBounds =  true
        updateButton.layer.borderColor = UIColor.sapphire.cgColor
        updateButton.layer.borderWidth =  2
        updateButton.layer.opacity = 1
        updateButton.setTitleColor(UIColor.sapphire, for: .normal)
        updateButton.titleLabel?.font = UIFont.textStyle9
        updateButton.contentHorizontalAlignment = .leading
        
        frameworkContainer.layer.cornerRadius = 10
        frameworkContainer.layer.masksToBounds =  true
        frameworkContainer.backgroundColor = UIColor.daisy
        frameworkContainer.layer.opacity = 1
        
        frameworkContainer.layer.masksToBounds = false
        frameworkContainer.layer.shadowColor = UIColor.black.cgColor
        frameworkContainer.layer.shadowOpacity = 0.2
        frameworkContainer.layer.shadowOffset = .zero
        frameworkContainer.layer.shadowRadius = 1
        
        macroContainer.layer.cornerRadius = 10
        macroContainer.layer.masksToBounds =  true
        macroContainer.backgroundColor = UIColor.daisy
        macroContainer.layer.opacity = 1
        
        macroContainer.layer.masksToBounds = false
        macroContainer.layer.shadowColor = UIColor.black.cgColor
        macroContainer.layer.shadowOpacity = 0.2
        macroContainer.layer.shadowOffset = .zero
        macroContainer.layer.shadowRadius = 1
        
        microContainer.layer.cornerRadius = 10
        microContainer.layer.masksToBounds =  true
        microContainer.backgroundColor = UIColor.daisy
        microContainer.layer.opacity = 1
        
        microContainer.layer.masksToBounds = false
        microContainer.layer.shadowColor = UIColor.black.cgColor
        microContainer.layer.shadowOpacity = 0.2
        microContainer.layer.shadowOffset = .zero
        microContainer.layer.shadowRadius = 1
        
        budgetContainer.layer.cornerRadius = 10
        budgetContainer.layer.masksToBounds =  true
        budgetContainer.backgroundColor = UIColor.daisy
        budgetContainer.layer.opacity = 1
        
        budgetContainer.layer.masksToBounds = false
        budgetContainer.layer.shadowColor = UIColor.black.cgColor
        budgetContainer.layer.shadowOpacity = 0.2
        budgetContainer.layer.shadowOffset = .zero
        budgetContainer.layer.shadowRadius = 1
        
        prepreContainer.layer.cornerRadius = 10
        prepreContainer.layer.masksToBounds =  true
        prepreContainer.backgroundColor = UIColor.daisy
        prepreContainer.layer.opacity = 1
        
        prepreContainer.layer.masksToBounds = false
        prepreContainer.layer.shadowColor = UIColor.black.cgColor
        prepreContainer.layer.shadowOpacity = 0.2
        prepreContainer.layer.shadowOffset = .zero
        prepreContainer.layer.shadowRadius = 1
        
        directorContainer.layer.cornerRadius = 10
        directorContainer.layer.masksToBounds =  true
        directorContainer.backgroundColor = UIColor.daisy
        directorContainer.layer.opacity = 1
        
        directorContainer.layer.masksToBounds = false
        directorContainer.layer.shadowColor = UIColor.black.cgColor
        directorContainer.layer.shadowOpacity = 0.2
        directorContainer.layer.shadowOffset = .zero
        directorContainer.layer.shadowRadius = 1
        
        productionContainer.layer.cornerRadius = 10
        productionContainer.layer.masksToBounds =  true
        productionContainer.backgroundColor = UIColor.daisy
        productionContainer.layer.opacity = 1
        
        productionContainer.layer.masksToBounds = false
        productionContainer.layer.shadowColor = UIColor.black.cgColor
        productionContainer.layer.shadowOpacity = 0.2
        productionContainer.layer.shadowOffset = .zero
        productionContainer.layer.shadowRadius = 1
        
        shotListContainer.layer.cornerRadius = 10
        shotListContainer.layer.masksToBounds =  true
        shotListContainer.backgroundColor = UIColor.daisy
        shotListContainer.layer.opacity = 1
        
        shotListContainer.layer.masksToBounds = false
        shotListContainer.layer.shadowColor = UIColor.black.cgColor
        shotListContainer.layer.shadowOpacity = 0.2
        shotListContainer.layer.shadowOffset = .zero
        shotListContainer.layer.shadowRadius = 1
        
        constructionContainer.layer.cornerRadius = 10
        constructionContainer.layer.masksToBounds =  true
        constructionContainer.backgroundColor = UIColor.daisy
        constructionContainer.layer.opacity = 1
        
        constructionContainer.layer.masksToBounds = false
        constructionContainer.layer.shadowColor = UIColor.black.cgColor
        constructionContainer.layer.shadowOpacity = 0.2
        constructionContainer.layer.shadowOffset = .zero
        constructionContainer.layer.shadowRadius = 1
        
        thumbnailView.layer.borderWidth = 0.5
        thumbnailView.layer.borderColor = UIColor.lightGray.cgColor
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
    
    @IBAction func budgetButtonPressed() {
        if budgetComplete {
            budgetComplete = false
            let origImage = UIImage(named: "frame3")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            budgetCompletedButton.setImage(tintedImage, for: .normal)
            budgetCompletedButton.tintColor = .red
        } else {
            budgetComplete = true
            budgetCompletedButton.setImage(UIImage(named: "frame3") , for: .normal)
            budgetCompletedButton.tintColor = .green
        }
    }
    
    @IBAction func frameworkButtonPressed() {
        if frameworkPressed {
            frameworkPressed = false
            let origImage = UIImage(named: "frame3")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            frameworkCompletedButton.setImage(tintedImage, for: .normal)
            frameworkCompletedButton.tintColor = .red
        } else {
            frameworkPressed = true
            frameworkCompletedButton.setImage(UIImage(named: "frame3") , for: .normal)
            frameworkCompletedButton.tintColor = .green
        }
    }
    
    @IBAction func macroButtonPressed() {
        if macroPressed {
            macroPressed = false
            let origImage = UIImage(named: "frame3")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            macroCompletedButton.setImage(tintedImage, for: .normal)
            macroCompletedButton.tintColor = .red
        } else {
            macroPressed = true
            macroCompletedButton.setImage(UIImage(named: "frame3") , for: .normal)
            macroCompletedButton.tintColor = .green
        }
    }
    
    @IBAction func microButtonPressed() {
        if microPressed {
            microPressed = false
            let origImage = UIImage(named: "frame3")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            microCompletedButton.setImage(tintedImage, for: .normal)
            microCompletedButton.tintColor = .red
        } else {
            microPressed = true
            microCompletedButton.setImage(UIImage(named: "frame3") , for: .normal)
            microCompletedButton.tintColor = .green
        }
    }
    
    @IBAction func updateButtonPressed() {
        view.endEditing(true)
        
        let title = self.titleLabel.text
        
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
        
        let budgetcomplete = self.budgetComplete
        
        var currentStage = ""
        
        if frameworkPressed {
            currentStage = "Macro"
        }
        
        if macroPressed {
            currentStage = "Micro"
        }
        
        if microPressed {
            currentStage = "Filmed"
        }
        
        if !frameworkPressed && !microPressed && !macroPressed {
            currentStage = "Framework"
        }
        
        let videoId = videoInformation.first?.id
        
        model.updateVideoFromMasterDocs(videoId ?? 0, title : title ?? " ", budgetcomplete: budgetcomplete, currentstage: currentStage, director: director , producer: producer , filmdate: filmdate, postdate: postdate, macrodate: (macroDeadline?.postgresDate(in: TimeZone.current))!, microdate: (microDeadline?.postgresDate(in: TimeZone.current))!, frameworkdate: frameworkDeadline.postgresDate(in: TimeZone.current)) { result in
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

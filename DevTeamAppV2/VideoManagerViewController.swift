//
//  VideoManagerViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 9/5/23.
//

import PostgresClientKit
import UIKit

class VideoManagerViewController: UIViewController {
    let model = DatabaseManager.shared.connectToDatabase()
    let currentUser = CurrentUser.shared
    var videoInformation = [Model.Video]()
    
    var del: VideoManagerDelegate?
    
    @IBOutlet var welcomeField: UILabel!
    @IBOutlet var userThumbnail: UIImageView!
    
    @IBOutlet var startDateField: UIDatePicker!
    @IBOutlet var frameworkDateField: UIDatePicker!
    @IBOutlet var macroDateField: UIDatePicker!
    @IBOutlet var microDateField: UIDatePicker!
    @IBOutlet var filmDateField: UIDatePicker!
    @IBOutlet var postDateField: UIDatePicker!
    @IBOutlet var videoThumbnail: UIImageView!
    
    @IBOutlet var taskButton: UIButton!
    @IBOutlet var videoButton: UIButton!
    @IBOutlet var userButton: UIButton!
    
    @IBOutlet var directorMenu: UIButton!
    @IBOutlet var producerMenu: UIButton!
    
    @IBOutlet var frameworkView: UIView!
    @IBOutlet var macroView: UIView!
    @IBOutlet var microView: UIView!
    @IBOutlet var postView: UIView!
    
    @IBOutlet var dashboardButton: UIButton!
    
    @IBOutlet var videoMenu: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setVideoMenu()
        
        startDateField.isUserInteractionEnabled = false
        
        setDirectorButton(" ")
        setProducerButton(" ")
        
        welcomeField.text = currentUser.getCurrentUserName()
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
        
        taskButton.layer.cornerRadius = 7
        taskButton.layer.masksToBounds =  true
        taskButton.backgroundColor = UIColor.salt2
        taskButton.layer.opacity = 1
        taskButton.setTitleColor(UIColor.black, for: .normal)
        taskButton.titleLabel?.font = UIFont.textStyle9
        taskButton.contentHorizontalAlignment = .leading
        
        userButton.layer.cornerRadius = 7
        userButton.layer.masksToBounds =  true
        userButton.backgroundColor = UIColor.salt2
        userButton.layer.opacity = 1
        userButton.setTitleColor(UIColor.black, for: .normal)
        userButton.titleLabel?.font = UIFont.textStyle9
        userButton.contentHorizontalAlignment = .leading
        
        videoButton.layer.cornerRadius = 7
        videoButton.layer.masksToBounds =  true
        videoButton.backgroundColor = UIColor.black
        videoButton.layer.opacity = 1
        videoButton.setTitleColor(UIColor.daisy, for: .normal)
        videoButton.titleLabel?.font = UIFont.textStyle9
        videoButton.contentHorizontalAlignment = .leading
        
        dashboardButton.layer.cornerRadius = 7
        dashboardButton.layer.masksToBounds =  true
        dashboardButton.layer.borderColor = UIColor.sapphire.cgColor
        dashboardButton.layer.borderWidth =  2
        dashboardButton.layer.opacity = 1
        dashboardButton.setTitleColor(UIColor.sapphire, for: .normal)
        dashboardButton.titleLabel?.font = UIFont.textStyle9
        dashboardButton.contentHorizontalAlignment = .leading
        
        frameworkView.layer.cornerRadius = 10
        frameworkView.layer.masksToBounds =  true
        frameworkView.layer.opacity = 1
        frameworkView.layer.masksToBounds = false
        frameworkView.layer.borderColor = UIColor.lightGray.cgColor
        frameworkView.layer.borderWidth = 0.5
        frameworkView.layer.shadowColor = UIColor.black.cgColor
        frameworkView.layer.shadowOpacity = 0.2
        frameworkView.layer.shadowOffset = .zero
        frameworkView.layer.shadowRadius = 1
        
        macroView.layer.cornerRadius = 10
        macroView.layer.masksToBounds =  true
        macroView.layer.opacity = 1
        macroView.layer.masksToBounds = false
        macroView.layer.shadowColor = UIColor.black.cgColor
        macroView.layer.shadowOpacity = 0.2
        macroView.layer.shadowOffset = .zero
        macroView.layer.shadowRadius = 1
        macroView.layer.borderColor = UIColor.lightGray.cgColor
        macroView.layer.borderWidth = 0.5
        
        microView.layer.cornerRadius = 10
        microView.layer.masksToBounds =  true
        microView.layer.opacity = 1
        microView.layer.masksToBounds = false
        microView.layer.shadowColor = UIColor.black.cgColor
        microView.layer.shadowOpacity = 0.2
        microView.layer.shadowOffset = .zero
        microView.layer.shadowRadius = 1
        microView.layer.borderColor = UIColor.lightGray.cgColor
        microView.layer.borderWidth = 0.5
        
        postView.layer.cornerRadius = 10
        postView.layer.masksToBounds =  true
        postView.layer.opacity = 1
        postView.layer.masksToBounds = false
        postView.layer.shadowColor = UIColor.black.cgColor
        postView.layer.shadowOpacity = 0.2
        postView.layer.shadowOffset = .zero
        postView.layer.shadowRadius = 1
        postView.layer.borderColor = UIColor.lightGray.cgColor
        postView.layer.borderWidth = 0.5
        
        videoThumbnail.layer.borderWidth = 0.5
        videoThumbnail.layer.borderColor = UIColor.lightGray.cgColor
        
        userThumbnail.layer.cornerRadius = 10
        userThumbnail.layer.borderWidth = 1
        userThumbnail.layer.borderColor = UIColor.black.cgColor
        
//        startDateField.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .red
        startDateField.layer.backgroundColor = UIColor.lightGray.cgColor
        startDateField.layer.cornerRadius = 10
        
        filmDateField.layer.backgroundColor = UIColor.lightGray.cgColor
        filmDateField.layer.cornerRadius = 10
        
        frameworkDateField.layer.backgroundColor = UIColor.lightGray.cgColor
        frameworkDateField.layer.cornerRadius = 10
        
        macroDateField.layer.backgroundColor = UIColor.lightGray.cgColor
        macroDateField.layer.cornerRadius = 10
        
        microDateField.layer.backgroundColor = UIColor.lightGray.cgColor
        microDateField.layer.cornerRadius = 10
        
        postDateField.layer.backgroundColor = UIColor.lightGray.cgColor
        postDateField.layer.cornerRadius = 10
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
        } else if director == "Sean" {
            directorMenu.menu = UIMenu(children: [
                UIAction(title : "Kyle", handler: optionClosure),
                UIAction(title : "Drew", handler: optionClosure),
                UIAction(title : "Sean", state: .on, handler: optionClosure)])
        } else {
            directorMenu.menu = UIMenu(children: [
                UIAction(title: "Directors", state: .on, handler: optionClosure),
                UIAction(title : "Kyle", handler: optionClosure),
                UIAction(title : "Drew", handler: optionClosure),
                UIAction(title : "Sean", handler: optionClosure)])
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
        } else if producer == "Locoya" {
            producerMenu.menu = UIMenu(children: [
                UIAction(title : "Dustin", handler: optionClosure),
                UIAction(title : "Will", handler: optionClosure),
                UIAction(title : "Mike", handler: optionClosure),
                UIAction(title : "Rachel", handler: optionClosure),
                UIAction(title: "Locoya", state: .on, handler: optionClosure)])
        } else {
            producerMenu.menu = UIMenu(children: [
                UIAction(title: "Producers", state: .on, handler: optionClosure),
                UIAction(title : "Dustin", handler: optionClosure),
                UIAction(title : "Will", handler: optionClosure),
                UIAction(title : "Mike", handler: optionClosure),
                UIAction(title : "Rachel", handler: optionClosure),
                UIAction(title: "Locoya", handler: optionClosure)])
        }
        
        producerMenu.showsMenuAsPrimaryAction = true
        producerMenu.changesSelectionAsPrimaryAction = true
    }
    
    func setVideoMenu() {
        let optionClosure = {(action: UIAction) in
            self.displayVideoInfo()}
        
        model.getAllVideos() { result in
            do {
                self.videoInformation = try result.get()
                
                var children: [UIMenuElement] = []
                
                let a = UIAction(title: "Current Videos", state: .on, handler: optionClosure)
                children.append(a)
                
                for video in self.videoInformation {
                    let action = UIAction(title: video.title, handler: optionClosure)
                    children.append(action)
                }
                self.videoMenu.menu = UIMenu(children: children)
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
        
        videoMenu.showsMenuAsPrimaryAction = true
        videoMenu.changesSelectionAsPrimaryAction = true
    }
    
    func displayVideoInfo() {
        let title = videoMenu.menu?.selectedElements.first?.title ?? ""
        
        if title != "" {
            model.videoInformation(title) { result in
                do {
                    self.videoInformation = try result.get()
                    
                    self.filmDateField.date = self.videoInformation.first?.filmdate.date(in: TimeZone.current) ?? Date()
                    self.postDateField.date = self.videoInformation.first?.postdate.date(in: TimeZone.current) ?? Date()
                    self.startDateField.date = (self.videoInformation.first?.startdate.date(in: TimeZone.current))!
                    self.frameworkDateField.date = (self.videoInformation.first?.frameworkdate.date(in: TimeZone.current))!
                    self.macroDateField.date = (self.videoInformation.first?.macrodate.date(in: TimeZone.current))!
                    self.microDateField.date = (self.videoInformation.first?.microdate.date(in: TimeZone.current))!
                    
                    self.setDirectorButton(self.videoInformation.first?.leaddirector ?? " ")
                    self.setProducerButton(self.videoInformation.first?.leadproducer ?? " ")
                    
                    let dataString = self.videoInformation.first?.thumbnail.first ?? ""
                    let sliceOne = String(dataString.dropFirst())
                    let sliceTwo = String(sliceOne.dropLast())
                    let thumbnailData = Data(base64Encoded: sliceTwo)
                    if let thumbnailData = thumbnailData {
                        self.videoThumbnail.image = UIImage(data: thumbnailData)
                    }
                } catch {
                    Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                }
            }
        }
    }
    
    @IBAction func updateVideo() {
        let filmdate = self.filmDateField.date.postgresDate(in: TimeZone.current)
        let postdate = self.postDateField.date.postgresDate(in: TimeZone.current)
//        let startdate = self.startDateField.date.postgresDate(in: TimeZone.current)
        let frameworkdate = self.frameworkDateField.date.postgresDate(in: TimeZone.current)
        let macrodate = self.macroDateField.date.postgresDate(in: TimeZone.current)
        let microdate = self.microDateField.date.postgresDate(in: TimeZone.current)
        
        let leaddirector = self.directorMenu.menu?.selectedElements.first?.title
        let leadproducer = self.producerMenu.menu?.selectedElements.first?.title
        
        let title = videoMenu.menu?.selectedElements.first?.title ?? ""
        
        model.updateVideoDates(title, filmdate: filmdate, postdate: postdate, frameworkdate: frameworkdate, macrodate: macrodate, microdate: microdate, leaddirector: leaddirector!, leadproducer: leadproducer!) { result in
            do {
                self.videoInformation = try result.get()
                Postgres.logger.fine("Length of update return list: " + String(self.videoInformation.count))
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.filmDateField.date = Date()
                    self.postDateField.date = Date()
                    self.startDateField.date = Date()
                    self.frameworkDateField.date = Date()
                    self.macroDateField.date = Date()
                    self.microDateField.date = Date()
                    self.setVideoMenu()
                    self.setDirectorButton(" ")
                    self.setProducerButton(" ")
                    self.videoThumbnail.image = UIImage(named: "frame2")
                }
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func resetVideo() {
        let title = videoMenu.menu?.selectedElements.first?.title ?? ""
        
        var frameworkdate = Date()
        var filmdate = Date()
        
        if videoInformation.first?.productiontype == "Thirty" {
            frameworkdate = startDateField.date
            filmdate = Calendar.current.date(byAdding: .day, value: 30, to: startDateField.date)!
        } else if videoInformation.first?.productiontype == "Sixty" {
            filmdate = Calendar.current.date(byAdding: .day, value: 60, to: startDateField.date)!
            frameworkdate = Calendar.current.date(byAdding: .day, value: 7, to: startDateField.date)!
        } else {
            filmdate = Calendar.current.date(byAdding: .day, value: 90, to: startDateField.date)!
            frameworkdate = Calendar.current.date(byAdding: .day, value: 14, to: startDateField.date)!
        }
        
        let macrodate = Calendar.current.date(byAdding: .day, value: -30, to: filmdate)
        let microdate = Calendar.current.date(byAdding: .day, value: -14, to: filmdate)
        let postdate = Calendar.current.date(byAdding: .day, value: 30, to: filmdate)
        
        let leaddirector = self.directorMenu.menu?.selectedElements.first?.title
        let leadproducer = self.producerMenu.menu?.selectedElements.first?.title
        
        model.updateVideoDates(title, filmdate: filmdate.postgresDate(in: TimeZone.current), postdate: (postdate?.postgresDate(in: TimeZone.current))!, frameworkdate: frameworkdate.postgresDate(in: TimeZone.current), macrodate: (macrodate?.postgresDate(in: TimeZone.current))!, microdate: (microdate?.postgresDate(in: TimeZone.current))!, leaddirector: leaddirector!, leadproducer: leadproducer!) { result in
            do {
                self.videoInformation = try result.get()
                Postgres.logger.fine("Length of update return list: " + String(self.videoInformation.count))
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.filmDateField.date = Date()
                    self.postDateField.date = Date()
                    self.startDateField.date = Date()
                    self.frameworkDateField.date = Date()
                    self.macroDateField.date = Date()
                    self.microDateField.date = Date()
                    self.setVideoMenu()
                    self.setDirectorButton(" ")
                    self.setProducerButton(" ")
                    self.videoThumbnail.image = UIImage(named: "frame2")
                }
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func deleteVideo() {
        let title = videoMenu.menu?.selectedElements.first?.title ?? ""
        
        model.deleteVideo(title) { result in
            do {
                self.videoInformation = try result.get()
                if self.videoInformation.first?.title == title {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.filmDateField.date = Date()
                        self.postDateField.date = Date()
                        self.startDateField.date = Date()
                        self.frameworkDateField.date = Date()
                        self.macroDateField.date = Date()
                        self.microDateField.date = Date()
                        self.setVideoMenu()
                        self.setDirectorButton(" ")
                        self.setProducerButton(" ")
                        self.videoThumbnail.image = UIImage(named: "frame2")
                    }
                }
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        del?.reloadVideosAfterManagerCloses()
    }
    
    @IBAction func closeButtonPressed() {
        del?.reloadVideosAfterManagerCloses()
        self.dismiss(animated: true)
    }
}

protocol VideoManagerDelegate {
    func reloadVideosAfterManagerCloses()
}

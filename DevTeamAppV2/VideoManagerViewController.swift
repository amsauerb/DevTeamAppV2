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
    var videoInformation = [Model.Video]()
    
    var del: VideoManagerDelegate?
    
    @IBOutlet var startDateField: UIDatePicker!
    @IBOutlet var frameworkDateField: UIDatePicker!
    @IBOutlet var macroDateField: UIDatePicker!
    @IBOutlet var microDateField: UIDatePicker!
    @IBOutlet var filmDateField: UIDatePicker!
    @IBOutlet var postDateField: UIDatePicker!
    
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet var videoMenu: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        errorLabel.text = ""
        setVideoMenu()
        
        startDateField.isUserInteractionEnabled = false
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
        
        let title = videoMenu.menu?.selectedElements.first?.title ?? ""
        
        model.updateVideoDates(title, filmdate: filmdate, postdate: postdate, frameworkdate: frameworkdate, macrodate: macrodate, microdate: microdate) { result in
            do {
                self.videoInformation = try result.get()
                Postgres.logger.fine("Length of update return list: " + String(self.videoInformation.count))
                self.errorLabel.text = "The video was updated successfully"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.filmDateField.date = Date()
                    self.postDateField.date = Date()
                    self.startDateField.date = Date()
                    self.frameworkDateField.date = Date()
                    self.macroDateField.date = Date()
                    self.microDateField.date = Date()
                    self.errorLabel.text = ""
                    self.setVideoMenu()
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
        
        model.updateVideoDates(title, filmdate: filmdate.postgresDate(in: TimeZone.current), postdate: (postdate?.postgresDate(in: TimeZone.current))!, frameworkdate: frameworkdate.postgresDate(in: TimeZone.current), macrodate: (macrodate?.postgresDate(in: TimeZone.current))!, microdate: (microdate?.postgresDate(in: TimeZone.current))!) { result in
            do {
                self.videoInformation = try result.get()
                Postgres.logger.fine("Length of update return list: " + String(self.videoInformation.count))
                self.errorLabel.text = "The video was reset successfully"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.filmDateField.date = Date()
                    self.postDateField.date = Date()
                    self.startDateField.date = Date()
                    self.frameworkDateField.date = Date()
                    self.macroDateField.date = Date()
                    self.microDateField.date = Date()
                    self.errorLabel.text = ""
                    self.setVideoMenu()
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
                    self.errorLabel.text = "Video deletion successful"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.filmDateField.date = Date()
                        self.postDateField.date = Date()
                        self.startDateField.date = Date()
                        self.frameworkDateField.date = Date()
                        self.macroDateField.date = Date()
                        self.microDateField.date = Date()
                        self.errorLabel.text = ""
                        self.setVideoMenu()
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

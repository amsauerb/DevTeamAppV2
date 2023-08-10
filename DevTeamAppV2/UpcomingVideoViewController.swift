//
//  UpcomingVideoViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/29/23.
//

import PostgresClientKit
import UIKit
import Foundation

class UpcomingVideoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let model = DatabaseManager.shared.connectToDatabase()
    let selectedVideo = SelectedVideo.shared
    
    var foundProducers = [String]()
    
    @IBOutlet var producerMenu: UIButton!
    @IBOutlet var directorMenu: UIButton!
    @IBOutlet var errorView: UITextView!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var showButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        errorView.text = ""
        errorView.isUserInteractionEnabled = false
        
        setDirectorButton()
        setProducerButton()
    }
    
    func setDirectorButton() {
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
        directorMenu.menu = UIMenu(children: [
            UIAction(title: "All", state: .on, handler: optionClosure),
            UIAction(title : "Dustin", handler: optionClosure),
            UIAction(title : "Will", handler: optionClosure),
            UIAction(title : "Mike", handler: optionClosure),
            UIAction(title : "Rachel", handler: optionClosure),
                UIAction(title: "Locoya", handler: optionClosure)])
        
        directorMenu.showsMenuAsPrimaryAction = true
        directorMenu.changesSelectionAsPrimaryAction = true
    }
    
    func setProducerButton() {
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
        producerMenu.menu = UIMenu(children: [
            UIAction(title: "All", state: .on, handler: optionClosure),
            UIAction(title : "Kyle", handler: optionClosure),
            UIAction(title : "Drew", handler: optionClosure),
            UIAction(title : "Sean", handler: optionClosure)])
        
        producerMenu.showsMenuAsPrimaryAction = true
        producerMenu.changesSelectionAsPrimaryAction = true
    }
    
    @IBAction func showButtonPressed() {
        view.endEditing(true)
        let director = directorMenu.menu?.selectedElements.first?.title ?? ""
        let producer = producerMenu.menu?.selectedElements.first?.title ?? ""
        
        self.foundProducers.removeAll()
        
        if director == "All" && producer == "All" {
            model.getAllVideos() { result in
                do {
                    self.videoInformation = try result.get()
                    if self.videoInformation.count > 0 {
                        self.errorView.text = "All Videos"
                        self.tableView.reloadData()
                    } else {
                        self.errorView.text = "No videos found"
                    }
                } catch {
                    Postgres.logger.severe("Error getting video list: \(String(describing: error))")
                }
            }
        } else if director == "All" {
            model.videoListByProducer(producer) { result in
                do {
                    self.videoInformation = try result.get()
                    if self.videoInformation.count > 0 {
                        self.errorView.text = "Videos for: " + producer
                        self.tableView.reloadData()
                    } else {
                        self.errorView.text = "No videos found"
                    }
                } catch {
                    Postgres.logger.severe("Error getting video list: \(String(describing: error))")
                }
            }
        } else if producer == "All" {
            model.videoListByDirector(director) { result in
                do {
                    self.videoInformation = try result.get()
                    if self.videoInformation.count > 0 {
                        self.errorView.text = "Videos for: " + director
                        self.tableView.reloadData()
                    } else {
                        self.errorView.text = "No videos found"
                    }
                } catch {
                    Postgres.logger.severe("Error getting video list: \(String(describing: error))")
                }
            }
        } else {
            model.videoListByDirectorProducer(producer, director: director) { result in
                do {
                    self.videoInformation = try result.get()
                    if self.videoInformation.count > 0 {
                        self.errorView.text = "Videos for: " + director + " and " + producer
                    } else {
                        self.errorView.text = "No videos found"
                    }
                    self.tableView.reloadData()
                    self.tableView.allowsSelection = true
                } catch {
                    Postgres.logger.severe("Error getting video list: \(String(describing: error))")
                }
            }
        }
    }
    
    var videoInformation = [Model.Video]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections = 0
        for video in videoInformation {
            var notFound = true
            for producer in self.foundProducers {
                if video.leadproducer == producer {
                    notFound = false
                }
            }
            
            if notFound {
                numOfSections += 1
                self.foundProducers.append(video.leadproducer)
            }
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.foundProducers[section] + "'s Team"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRows = 0
        for video in videoInformation {
            if video.leadproducer == foundProducers[section] {
                numOfRows += 1
            }
        }
        
        return numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "VideoCell")
        
        let videoSubset = videoInformation.filter {$0.leadproducer == foundProducers[indexPath.section]}
        let video = videoSubset[indexPath.row]
        let text = String(describing: video.title)
        
        let currentDate = Date()
        let filmdate = video.filmdate.date(in: TimeZone.current)
        let daysUntilFilming = String(Calendar.current.dateComponents([.day], from: currentDate, to: filmdate).day ?? 0)
        
        let detailText = "Days Until Filming: " + daysUntilFilming
        
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detailText
        
        return cell
    }
    
    var selectedIndex = 0
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Postgres.logger.fine("Clicking does something")
        selectedIndex = indexPath.row
        self.selectedVideo.setSelectedVideoTitle(title: self.videoInformation[selectedIndex].title)
            
        tableView.deselectRow(at: indexPath, animated: false)
            
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "videoMasterDocView") as? VideoMasterDocViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func upcomingVideoButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "dashboardView") as? DashboardViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func teamButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "teamView") as? TeamViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func addVideoButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "addVideoView") as? AddVideoViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func videoReviewButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "videoReviewView") as? VideoReviewViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func videoLibraryButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "videoLibraryView") as? VideoLibraryViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }

}

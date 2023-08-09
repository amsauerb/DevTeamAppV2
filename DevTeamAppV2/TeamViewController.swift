//
//  TeamViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/29/23.
//

import PostgresClientKit
import UIKit

class TeamViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let model = DatabaseManager.shared.connectToDatabase()
    let selectedVideo = SelectedVideo.shared
    
    var foundProducers = [String]()

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var errorView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        errorView.text = ""
        errorView.isUserInteractionEnabled = false
        
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
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "upcomingVideoView") as? UpcomingVideoViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func teamButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "dashboardView") as? DashboardViewController
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

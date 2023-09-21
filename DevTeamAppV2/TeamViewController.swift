//
//  TeamViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/29/23.
//

import PostgresClientKit
import UIKit

class TeamViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, VideoMasterDelegate {
    
    let model = DatabaseManager.shared.connectToDatabase()
    let selectedVideo = SelectedVideo.shared
    
    var foundProducers = [String]()
    
    var selectedDate = Date()
    let cal = Calendar.current
    var totalSquares = [String]()
    var videosOnDay = [String]()

    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var calendar: UICollectionView!
    @IBOutlet var dateStack: UIStackView!
    @IBOutlet var calendarTable: UITableView!
    
    @IBOutlet var tableVideoView: UITableView!
    @IBOutlet var errorView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        tableVideoView.dataSource = self
        tableVideoView.delegate = self
        
        calendar.dataSource = self
        calendar.delegate = self
        
        calendarTable.dataSource = self
        calendarTable.delegate = self
        
        errorView.text = ""
        errorView.isUserInteractionEnabled = false
        
        dateStack.isHidden = true
        calendar.isHidden = true
        leftButton.isHidden = true
        rightButton.isHidden = true
        calendarTable.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        foundProducers.removeAll()
        
        model.getAllVideos() { result in
            do {
                self.videoInformation = try result.get()
                if self.videoInformation.count > 0 {
                    self.errorView.text = "All Videos"
                    self.tableVideoView.reloadData()
                    
                    self.setCellsView()
                    self.setMonthView()
                } else {
                    self.errorView.text = "No videos found"
                }
            } catch {
                Postgres.logger.severe("Error getting video list: \(String(describing: error))")
            }
        }
    }
    
    func reloadVideos() {
        foundProducers.removeAll()
        
        model.getAllVideos() { result in
            do {
                self.videoInformation = try result.get()
                if self.videoInformation.count > 0 {
                    self.errorView.text = "All Videos"
                    self.tableVideoView.reloadData()
                    
                    self.setCellsView()
                    self.setMonthView()
                } else {
                    self.errorView.text = "No videos found"
                }
            } catch {
                Postgres.logger.severe("Error getting video list: \(String(describing: error))")
            }
        }
    }
    
    func setCellsView() {
        let width = (calendar.frame.size.width - 2) / 8
        let height = (calendar.frame.size.height - 2) / 8
        
        let flowLayout = calendar.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    var videoInformation = [Model.Video]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections = 0
        if tableView == tableVideoView {
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
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == tableVideoView {
            return self.foundProducers[section] + "'s Team"
        }
        return "Videos"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableVideoView {
            var numOfRows = 0
            for video in videoInformation {
                if video.leadproducer == foundProducers[section] {
                    numOfRows += 1
                }
            }
            
            return numOfRows
        } else {
            return videosOnDay.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tableVideoView {
            let cell = tableVideoView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! CustomVideoCell
            
            var videoSubset = videoInformation.filter {$0.leadproducer == foundProducers[indexPath.section]}
            videoSubset = videoSubset.sorted(by: {$0.filmdate.date(in: TimeZone.current).compare($1.filmdate.date(in: TimeZone.current)) == .orderedAscending})
            let video = videoSubset[indexPath.row]
            
            cell.videoTitleLabel.text = video.title
            
            let currentDate = Date()
            let filmdate = video.filmdate.date(in: TimeZone.current)
            let daysUntilFilming = String(Calendar.current.dateComponents([.day], from: currentDate, to: filmdate).day ?? 0)
            
            cell.videoDaysRemainingLabel.text = "Days Until Filming: " + daysUntilFilming
            
            cell.videoFrameworkLabel.text = "Framework"
            cell.videoMacroLabel.text = "Macro"
            cell.videoMicroLabel.text = "Mirco"
            
            cell.videoFrameworkLabel.backgroundColor = UIColor.red
            cell.videoMacroLabel.backgroundColor = UIColor.red
            cell.videoMicroLabel.backgroundColor = UIColor.red
            
            if video.currentstage == "Macro" {
                cell.videoFrameworkLabel.backgroundColor = UIColor.green
            } else if video.currentstage == "Micro" {
                cell.videoFrameworkLabel.backgroundColor = UIColor.green
                cell.videoMacroLabel.backgroundColor = UIColor.green
            } else if video.currentstage != "Framework" {
                cell.videoFrameworkLabel.backgroundColor = UIColor.green
                cell.videoMacroLabel.backgroundColor = UIColor.green
                cell.videoMicroLabel.backgroundColor = UIColor.green
            }
            
            let dataString = video.thumbnail.first ?? ""
            let sliceOne = String(dataString.dropFirst())
            let sliceTwo = String(sliceOne.dropLast())
            let thumbnailData = Data(base64Encoded: sliceTwo)
            if let thumbnailData = thumbnailData {
                cell.videoImageView.image = UIImage(data: thumbnailData)
            }
            
            return cell
        } else {
            let cell = calendarTable.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! CustomVideoCell
            
            for video in videoInformation {
                if video.title == videosOnDay[indexPath.row] {
                    cell.videoTitleLabel.text = video.title
                    
                    let currentDate = Date()
                    let filmdate = video.filmdate.date(in: TimeZone.current)
                    let daysUntilFilming = String(Calendar.current.dateComponents([.day], from: currentDate, to: filmdate).day ?? 0)
                    
                    cell.videoDaysRemainingLabel.text = "Days Until Filming: " + daysUntilFilming
                    
                    cell.videoFrameworkLabel.text = "Framework"
                    cell.videoMacroLabel.text = "Macro"
                    cell.videoMicroLabel.text = "Mirco"
                    
                    cell.videoFrameworkLabel.backgroundColor = UIColor.red
                    cell.videoMacroLabel.backgroundColor = UIColor.red
                    cell.videoMicroLabel.backgroundColor = UIColor.red
                    
                    if video.currentstage == "Macro" {
                        cell.videoFrameworkLabel.backgroundColor = UIColor.green
                    } else if video.currentstage == "Micro" {
                        cell.videoFrameworkLabel.backgroundColor = UIColor.green
                        cell.videoMacroLabel.backgroundColor = UIColor.green
                    } else if video.currentstage != "Framework" {
                        cell.videoFrameworkLabel.backgroundColor = UIColor.green
                        cell.videoMacroLabel.backgroundColor = UIColor.green
                        cell.videoMicroLabel.backgroundColor = UIColor.green
                    }
                    
                    let dataString = video.thumbnail.first ?? ""
                    let sliceOne = String(dataString.dropFirst())
                    let sliceTwo = String(sliceOne.dropLast())
                    let thumbnailData = Data(base64Encoded: sliceTwo)
                    if let thumbnailData = thumbnailData {
                        cell.videoImageView.image = UIImage(data: thumbnailData)
                    }
                }
            }
            
            return cell
        }
    }
    
    var selectedIndex = 0
    var selectedSection = 0
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tableVideoView {
            selectedIndex = indexPath.row
            selectedSection = indexPath.section
            
            let videoSubset = videoInformation.filter {$0.leadproducer == foundProducers[selectedSection]}
            let video = videoSubset[selectedIndex]
            
            self.selectedVideo.setSelectedVideoTitle(title: video.title)
                
            tableVideoView.deselectRow(at: indexPath, animated: false)
        } else {
            let video = videoInformation.first {$0.title == videosOnDay[indexPath.row]}
            self.selectedVideo.setSelectedVideoTitle(title: video!.title)
            
            calendarTable.deselectRow(at: indexPath, animated: false)
        }
        
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "videoMasterDocView") as? VideoMasterDocViewController
        else {
            print("Button pressed failed")
            return
        }
        vc.del = self
        present(vc, animated:true)
    }
    
    func setMonthView()
    {
        totalSquares.removeAll()
        
        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        
        while count <= 42
        {
            if count <= startingSpaces || count - startingSpaces > daysInMonth {
                totalSquares.append("")
            }
            else {
                totalSquares.append(String(count - startingSpaces))
            }
            
            count += 1
        }
        
        if !calendar.isHidden {
            errorView.text = CalendarHelper().monthString(date: selectedDate) + " " + CalendarHelper().yearString(date: selectedDate)
        }
        
        calendar.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: "date", for: indexPath) as! CalendarCell
        
        cell.dateLabel.text = totalSquares[indexPath.item]
        cell.titleLabel.isHidden = true
        cell.eventImage.image = UIImage(data: Data())
        
        if totalSquares[indexPath.item] != "" {
            var currentDay = CalendarHelper().firstOfMonth(date: selectedDate)
            currentDay = cal.date(byAdding: .day, value: Int(totalSquares[indexPath.item])! - 1, to: currentDay)!
            
            for video in videoInformation {
                if currentDay == video.filmdate.date(in: TimeZone.current) {
                    let dataString = video.thumbnail.first ?? ""
                    let sliceOne = String(dataString.dropFirst())
                    let sliceTwo = String(sliceOne.dropLast())
                    let thumbnailData = Data(base64Encoded: sliceTwo)
                    if let thumbnailData = thumbnailData {
                        cell.eventImage.image = UIImage(data: thumbnailData)
                    }
                    
                    cell.titleLabel.text =  (cell.titleLabel.text ?? "") + video.title + ","
                }
            }
        }
        
        if cell.dateLabel.text == "" {
            cell.isUserInteractionEnabled = false
        } else {
            cell.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CalendarCell
        
        videosOnDay = cell?.titleLabel.text?.components(separatedBy: ",") ?? []
        calendarTable.reloadData()
    }
    
    @IBAction func previousMonth() {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
        videosOnDay.removeAll()
        calendarTable.reloadData()
    }
    
    @IBAction func nextMonth() {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
        videosOnDay.removeAll()
        calendarTable.reloadData()
    }
    
    @IBAction func toggleView() {
        if !tableVideoView.isHidden {
            tableVideoView.isHidden = true
            calendar.isHidden = false
            dateStack.isHidden = false
            leftButton.isHidden = false
            rightButton.isHidden = false
            calendarTable.isHidden = false
            setMonthView()
        } else {
            calendar.isHidden = true
            dateStack.isHidden = true
            leftButton.isHidden = true
            rightButton.isHidden = true
            calendarTable.isHidden = true
            tableVideoView.isHidden = false
        }
    }
}

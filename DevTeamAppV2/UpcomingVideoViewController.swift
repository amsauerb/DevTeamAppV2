//
//  UpcomingVideoViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/29/23.
//

import PostgresClientKit
import UIKit
import Foundation

class UpcomingVideoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, VideoMasterDelegate {
    
    
    let model = DatabaseManager.shared.connectToDatabase()
    let selectedVideo = SelectedVideo.shared
    
    var foundProducers = [String]()
    var videosPerSection = [[String]]()
    var section = [String]()
    
    var selectedDate = Date()
    let cal = Calendar.current
    var totalSquares = [String]()
    var videosOnDay = [String]()
    
    @IBOutlet var producerMenu: UIButton!
    @IBOutlet var directorMenu: UIButton!
    @IBOutlet var errorView: UITextView!
    
    @IBOutlet var tableVideoView: UITableView!
    
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet var dateStack: UIStackView!
    @IBOutlet var calendarLabel: UITextView!
    @IBOutlet var calendar: UICollectionView!
    @IBOutlet var calendarTable: UITableView!
    
    @IBOutlet var showButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        tableVideoView.dataSource = self
        tableVideoView.delegate = self
        
        errorView.text = ""
        errorView.isUserInteractionEnabled = false
        
        setDirectorButton()
        setProducerButton()
        
        calendarView.isHidden = true
        
        calendar.dataSource = self
        calendar.delegate = self
        
        calendarTable.dataSource = self
        calendarTable.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let director = directorMenu.menu?.selectedElements.first?.title ?? ""
        let producer = producerMenu.menu?.selectedElements.first?.title ?? ""
        
        
        if director == "All" && producer == "All" {
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
        } else if director == "All" {
            model.videoListByProducer(producer) { result in
                do {
                    self.videoInformation = try result.get()
                    if self.videoInformation.count > 0 {
                        self.errorView.text = "Videos for: " + producer
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
        } else if producer == "All" {
            model.videoListByDirector(director) { result in
                do {
                    self.videoInformation = try result.get()
                    if self.videoInformation.count > 0 {
                        self.errorView.text = "Videos for: " + director
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
        } else {
            model.videoListByDirectorProducer(producer, director: director) { result in
                do {
                    self.videoInformation = try result.get()
                    if self.videoInformation.count > 0 {
                        self.errorView.text = "Videos for: " + director + " and " + producer
                    } else {
                        self.errorView.text = "No videos found"
                    }
                    self.videoInformation = self.videoInformation.sorted(by: {$0.filmdate.date(in: TimeZone.current).compare($1.filmdate.date(in: TimeZone.current)) == .orderedAscending})
                    self.tableVideoView.reloadData()
                    
                    self.setCellsView()
                    self.setMonthView()
                } catch {
                    Postgres.logger.severe("Error getting video list: \(String(describing: error))")
                }
            }
        }
    }
    
    func setDirectorButton() {
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
        directorMenu.menu = UIMenu(children: [
            UIAction(title: "All", state: .on, handler: optionClosure),
            UIAction(title : "Kyle", handler: optionClosure),
            UIAction(title : "Drew", handler: optionClosure),
            UIAction(title : "Sean", handler: optionClosure)])
        
        directorMenu.showsMenuAsPrimaryAction = true
        directorMenu.changesSelectionAsPrimaryAction = true
    }
    
    func setProducerButton() {
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
        producerMenu.menu = UIMenu(children: [
            UIAction(title: "All", state: .on, handler: optionClosure),
            UIAction(title : "Dustin", handler: optionClosure),
            UIAction(title : "Will", handler: optionClosure),
            UIAction(title : "Mike", handler: optionClosure),
            UIAction(title : "Rachel", handler: optionClosure),
                UIAction(title: "Locoya", handler: optionClosure)])
        
        producerMenu.showsMenuAsPrimaryAction = true
        producerMenu.changesSelectionAsPrimaryAction = true
    }
    
    func reloadVideos() {
        let director = directorMenu.menu?.selectedElements.first?.title ?? ""
        let producer = producerMenu.menu?.selectedElements.first?.title ?? ""
        
        
        if director == "All" && producer == "All" {
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
        } else if director == "All" {
            model.videoListByProducer(producer) { result in
                do {
                    self.videoInformation = try result.get()
                    if self.videoInformation.count > 0 {
                        self.errorView.text = "Videos for: " + producer
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
        } else if producer == "All" {
            model.videoListByDirector(director) { result in
                do {
                    self.videoInformation = try result.get()
                    if self.videoInformation.count > 0 {
                        self.errorView.text = "Videos for: " + director
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
        } else {
            model.videoListByDirectorProducer(producer, director: director) { result in
                do {
                    self.videoInformation = try result.get()
                    if self.videoInformation.count > 0 {
                        self.errorView.text = "Videos for: " + director + " and " + producer
                    } else {
                        self.errorView.text = "No videos found"
                    }
                    self.videoInformation = self.videoInformation.sorted(by: {$0.filmdate.date(in: TimeZone.current).compare($1.filmdate.date(in: TimeZone.current)) == .orderedAscending})
                    self.tableVideoView.reloadData()
                    
                    self.setCellsView()
                    self.setMonthView()
                } catch {
                    Postgres.logger.severe("Error getting video list: \(String(describing: error))")
                }
            }
        }
    }
    
    @IBAction func showButtonPressed() {
        view.endEditing(true)
        let director = directorMenu.menu?.selectedElements.first?.title ?? ""
        let producer = producerMenu.menu?.selectedElements.first?.title ?? ""
        
        
        if director == "All" && producer == "All" {
            model.getAllVideos() { result in
                do {
                    self.videoInformation = try result.get()
                    if self.videoInformation.count > 0 {
                        self.errorView.text = "All Videos"
                        self.tableVideoView.reloadData()
                        
                        self.videosOnDay.removeAll()
                        self.calendarTable.reloadData()
                        self.setMonthView()
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
                        self.tableVideoView.reloadData()
                        
                        self.videosOnDay.removeAll()
                        self.calendarTable.reloadData()
                        self.setMonthView()
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
                        self.tableVideoView.reloadData()
                        
                        self.videosOnDay.removeAll()
                        self.calendarTable.reloadData()
                        self.setMonthView()
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
                    
                    self.tableVideoView.reloadData()
                    
                    self.videosOnDay.removeAll()
                    self.calendarTable.reloadData()
                    self.setMonthView()
                } catch {
                    Postgres.logger.severe("Error getting video list: \(String(describing: error))")
                }
            }
        }
    }
    
    var videoInformation = [Model.Video]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableVideoView {
            return videoInformation.count
        } else {
            return videosOnDay.count - 1
        }
        
    }
    
    var currentSection = 0
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableVideoView {
            let cell = tableVideoView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! CustomVideoCell
            
            videoInformation = videoInformation.sorted(by: {$0.filmdate.date(in: TimeZone.current).compare($1.filmdate.date(in: TimeZone.current)) == .orderedAscending})
            
            let video = videoInformation[indexPath.row]
            
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
        
        if tableView ==  tableVideoView {
            selectedIndex = indexPath.row
            self.selectedVideo.setSelectedVideoTitle(title: self.videoInformation[selectedIndex].title)
            
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
    
    func setCellsView() {
        let width = (calendar.frame.size.width - 2) / 8
        let height = (calendar.frame.size.height - 2) / 8
        
        let flowLayout = calendar.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
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
            calendarLabel.text = CalendarHelper().monthString(date: selectedDate) + " " + CalendarHelper().yearString(date: selectedDate)
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
        if calendarView.isHidden {
            tableVideoView.isHidden = true
            errorView.isHidden = true
            calendarView.isHidden = false
            setMonthView()
        } else {
            calendarView.isHidden = true
            tableVideoView.isHidden = false
            errorView.isHidden = false
        }
    }
}

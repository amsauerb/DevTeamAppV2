//
//  DashboardViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/30/23.
//

import PostgresClientKit
import UIKit
import UserNotifications

class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, TaskManagerDelegate, VideoManagerDelegate {
    
    let model = DatabaseManager.shared.connectToDatabase()
    let currentUser = CurrentUser.shared
    var videoInformation = [Model.Video]()
    
    var postVideoSubset = [Model.Video]()
    var prodVideoSubset = [Model.Video]()
    
    var tasksForUser = [Model.UserTask]()
    var taskInformation = [Model.Task]()
    
    @IBOutlet var welcomeField: UILabel!
    @IBOutlet var userThumbnail: UIImageView!
    
    @IBOutlet var collectionViewProd: UICollectionView!
    @IBOutlet var collectionViewPost: UICollectionView!
    @IBOutlet var collectionViewTasks: UICollectionView!
    
    @IBOutlet var manageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        collectionViewProd.dataSource = self
        collectionViewProd.delegate = self
        
        collectionViewPost.dataSource = self
        collectionViewPost.delegate = self
        
        collectionViewTasks.dataSource = self
        collectionViewTasks.delegate = self
        
        welcomeField.text = currentUser.getCurrentUserName() + "!"
        
        if currentUser.getCurrentUserRole() == "Developer" {
            manageButton.isHidden = true
        }
        
        loadPrettyViews()
        setManageButton()
    }
    
    func loadPrettyViews() {
        self.view.backgroundColor = UIColor.daisy


        userThumbnail.layer.opacity = 1


//        welcomeField.layer.opacity = 1
//        welcomeField.textColor = UIColor.black
//        welcomeField.numberOfLines = 0
//        welcomeField.font = UIFont.textStyle
//        welcomeField.textAlignment = .left
//        welcomeField.text = NSLocalizedString("welcome.back", comment: "")


        welcomeField.layer.opacity = 1
        welcomeField.textColor = UIColor.black
        welcomeField.numberOfLines = 0
        welcomeField.font = UIFont.textStyle2
        welcomeField.textAlignment = .left
        welcomeField.text = currentUser.getCurrentUserName()


        manageButton.layer.cornerRadius = 10
        manageButton.layer.masksToBounds =  true
        manageButton.backgroundColor = UIColor.sapphire
        manageButton.layer.opacity = 1
        manageButton.setTitleColor(UIColor.daisy, for: .normal)
        manageButton.titleLabel?.font = UIFont.textStyle8
        manageButton.contentHorizontalAlignment = .leading


//        currentTaskLabel.layer.opacity = 1
//        currentTaskLabel.textColor = UIColor.black
//        currentTaskLabel.numberOfLines = 0
//        currentTaskLabel.font = UIFont.textStyle8
//        currentTaskLabel.textAlignment = .left
//        currentTaskLabel.text = NSLocalizedString("current.tasks", comment: "")


//        userTaskList.rowHeight = UITableView.automaticDimension
//        userTaskList.estimatedRowHeight = 89
//        userTaskList.register(UINib(nibName: "CustomTaskCollectionCell", bundle: nil), forCellReuseIdentifier: "CustomTaskCollectionCell")
//        userTaskList.dataSource = self
//        userTaskList.delegate = self
        
        collectionViewPost.backgroundColor = UIColor.daisy
        collectionViewProd.backgroundColor = UIColor.daisy
        collectionViewTasks.backgroundColor = UIColor.daisy

//        videosToPostLabel.layer.opacity = 1
//        videosToPostLabel.textColor = UIColor.black
//        videosToPostLabel.numberOfLines = 0
//        videosToPostLabel.font = UIFont.textStyle8
//        videosToPostLabel.textAlignment = .left
//        videosToPostLabel.text = NSLocalizedString("videos.to.post", comment: "")
//
//
//        videosToPostList.rowHeight = UITableView.automaticDimension
//        videosToPostList.estimatedRowHeight = 92
//        videosToPostList.register(UINib(nibName: "CustomVideoDashboardListCell", bundle: nil), forCellReuseIdentifier: "CustomVideoDashboardListCell")
//        videosToPostList.dataSource = self
//        videosToPostList.delegate = self
//
//        videosInProductionLabel.layer.opacity = 1
//        videosInProductionLabel.textColor = UIColor.black
//        videosInProductionLabel.numberOfLines = 0
//        videosInProductionLabel.font = UIFont.textStyle8
//        videosInProductionLabel.textAlignment = .left
//        videosInProductionLabel.text = NSLocalizedString("videos.in.production", comment: "")
//
//
//        videosToProduceList.rowHeight = UITableView.automaticDimension
//        videosToProduceList.estimatedRowHeight = 92
//        videosToProduceList.register(UINib(nibName: "CustomVideoDashboardCell", bundle: nil), forCellReuseIdentifier: "CustomVideoDashboardCell")
//        videosToProduceList.dataSource = self
//        videosToProduceList.delegate = self

    }
    
    func setManageButton() {
        let manageUsers = {(action: UIAction) in self.userButtonPressed()}
        let manageTasks = {(action: UIAction) in self.taskButtonPressed()}
        let manageVideos = {(action: UIAction) in self.videoButtonPressed()}
        let optionClosure = {(action: UIAction) in print("Manage")}
        
        manageButton.menu = UIMenu(children: [
            UIAction(title: "Manage", state: .on, handler: optionClosure),
            UIAction(title: "Users", handler: manageUsers),
            UIAction(title: "Tasks", handler: manageTasks),
            UIAction(title: "Videos", handler: manageVideos)])
        
        manageButton.showsMenuAsPrimaryAction = true
        manageButton.changesSelectionAsPrimaryAction = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        model.getAllVideos() { result in
            do {
                self.videoInformation = try result.get()
                self.postVideoSubset = self.videoInformation.filter {$0.currentstage == "Polish" || $0.currentstage == "Filming"}
                self.prodVideoSubset = self.videoInformation.filter {$0.currentstage != "Polish" && $0.currentstage != "Filming" && $0.currentstage != "Posted"}
                
                self.postVideoSubset = self.postVideoSubset.sorted(by: {$0.filmdate.date(in: TimeZone.current).compare($1.filmdate.date(in: TimeZone.current)) == .orderedAscending})
                
                self.prodVideoSubset = self.prodVideoSubset.sorted(by: {$0.filmdate.date(in: TimeZone.current).compare($1.filmdate.date(in: TimeZone.current)) == .orderedAscending})
                
                self.collectionViewProd.reloadData()
                self.collectionViewPost.reloadData()
                
            } catch {
                Postgres.logger.severe("Error getting video list: \(String(describing: error))")
            }
        }
        
        model.getAllTasksForUID(currentUser.getCurrentUserID()) { result in
            do {
                self.tasksForUser = try result.get()
                
                self.collectionViewTasks.reloadData()
            } catch {
                Postgres.logger.severe("Error getting task list: \(String(describing: error))")
            }
        }
    }
    
    func reloadTasksAfterManagerClose() {
        model.getAllTasksForUID(currentUser.getCurrentUserID()) { result in
            do {
                self.tasksForUser = try result.get()
                
                self.collectionViewTasks.reloadData()
            } catch {
                Postgres.logger.severe("Error getting task list: \(String(describing: error))")
            }
        }
    }
    
    func reloadVideosAfterManagerCloses() {
        model.getAllVideos() { result in
            do {
                self.videoInformation = try result.get()
                self.postVideoSubset = self.videoInformation.filter {$0.currentstage == "Polish" || $0.currentstage == "Filming"}
                self.prodVideoSubset = self.videoInformation.filter {$0.currentstage != "Polish" && $0.currentstage != "Filming" && $0.currentstage != "Posted"}
                
                self.postVideoSubset = self.postVideoSubset.sorted(by: {$0.filmdate.date(in: TimeZone.current).compare($1.filmdate.date(in: TimeZone.current)) == .orderedAscending})
                
                self.prodVideoSubset = self.prodVideoSubset.sorted(by: {$0.filmdate.date(in: TimeZone.current).compare($1.filmdate.date(in: TimeZone.current)) == .orderedAscending})
                
                self.collectionViewProd.reloadData()
                self.collectionViewPost.reloadData()
                
            } catch {
                Postgres.logger.severe("Error getting video list: \(String(describing: error))")
            }
        }
    }
    
    func userButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "createAccountView") as? CreateAccountViewController
        else {
            print("Button pressed failed")
            return
        }
        setManageButton()
        present(vc, animated:true)
    }
    
    func videoButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "videoManagerView") as? VideoManagerViewController
        else {
            print("Button pressed failed")
            return
        }
        vc.del = self
        setManageButton()
        present(vc, animated:true)
    }
    
    func taskButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "taskManagerView") as? TaskManagerViewController
        else {
            print("Button pressed failed")
            return
        }
        
        vc.del = self
        setManageButton()
        present(vc, animated:true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewProd {
            let result = (prodVideoSubset.count != 0) ? prodVideoSubset.count : 1
            return result
        } else if collectionView == collectionViewTasks {
            let result = (tasksForUser.count != 0) ? tasksForUser.count : 1
            return result
        }
        let result = (postVideoSubset.count != 0) ? postVideoSubset.count : 1
        return result
    }
    
    @objc func updatePostDate(sender: UIDatePicker) {
        let postdate = sender.date.postgresDate(in: TimeZone.current)
        let path = IndexPath(row: sender.tag, section: 0)
        let video = postVideoSubset[path.row]
        model.updatePostDate(video.title, postdate: postdate) { result in
            do {
                let updateCheck = try result.get()
                if updateCheck.first?.postdate == video.postdate {
                    Postgres.logger.fine("Post date updated succesfully for: " + (updateCheck.first?.title ?? ""))
                }
            } catch {
                Postgres.logger.severe("Error in database communication: \(String(describing: error))")
            }
        }
    }
    
    @objc func finishTask(sender: UIButton) {
        let path = IndexPath(row: sender.tag, section: 0)
        let tid = tasksForUser[path.row].tid
        model.deleteTask(tid) { result in
            do {
                self.taskInformation = try result.get()
                if self.taskInformation.first!.tid == tid {
                    Postgres.logger.fine("Task finished")
                    
                    self.model.getAllTasksForUID(self.currentUser.getCurrentUserID()) { result in
                        do {
                            self.tasksForUser = try result.get()
                            
                            self.collectionViewTasks.reloadData()
                        } catch {
                            Postgres.logger.severe("Error getting task list: \(String(describing: error))")
                        }
                    }
                    
                    self.collectionViewTasks.reloadData()
                }
            } catch {
                Postgres.logger.severe("Error in database communication: \(String(describing: error))")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionViewPost {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionCell", for: indexPath) as! CutomVideoCollectionCell
            
            if postVideoSubset.count > 0 {
                let video = postVideoSubset[indexPath.row]
                
                let dataString = video.thumbnail.first ?? ""
                let sliceOne = String(dataString.dropFirst())
                let sliceTwo = String(sliceOne.dropLast())
                let thumbnailData = Data(base64Encoded: sliceTwo)
                if let thumbnailData = thumbnailData {
                    cell.videoCellImage.image = UIImage(data: thumbnailData)
                }
                
                cell.videoCellTitle.text = video.title
                cell.videoCellTitle.textColor = UIColor.black
                cell.videoCellTitle.numberOfLines = 0
                cell.videoCellTitle.font = UIFont.textStyle2
                cell.videoCellTitle.textAlignment = .left
                
                cell.videoCellDate.date = video.postdate.date(in: TimeZone.current)
                cell.videoCellDate.tag = indexPath.row
                cell.videoCellDate.addTarget(self,
                                             action: #selector(updatePostDate),
                                             for: .valueChanged)
                cell.videoCellDate.isHidden = false
                cell.videoCellImage.isHidden = false
            } else {
                cell.videoCellTitle.text = "No Videos To Post"
                cell.videoCellTitle.textColor = UIColor.black
                cell.videoCellTitle.numberOfLines = 0
                cell.videoCellTitle.font = UIFont.textStyle2
                cell.videoCellTitle.textAlignment = .left
                cell.videoCellDate.isHidden = true
                cell.videoCellImage.isHidden = true
            }
            
            return cell
        } else if collectionView == collectionViewTasks {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCollectionCell", for: indexPath) as! CustomTaskCollectionCell
            
            if tasksForUser.count > 0 {
                let tid = tasksForUser[indexPath.row].tid
                model.taskInformation(tid) { result in
                    do {
                        self.taskInformation = try result.get()
                        
                        cell.taskDeadlineDate.date = self.taskInformation.first!.deadline.date(in: TimeZone.current)
                        cell.taskInfo.text = self.taskInformation.first!.description
                        cell.taskInfo.textColor = UIColor.black
                        cell.taskInfo.numberOfLines = 0
                        cell.taskInfo.font = UIFont.textStyle14
                        cell.taskInfo.textAlignment = .left
                        
                        cell.videoTitle.text = self.taskInformation.first!.title
                        cell.videoTitle.textColor = UIColor.black
                        cell.videoTitle.numberOfLines = 0
                        cell.videoTitle.font = UIFont.textStyle14
                        cell.videoTitle.textAlignment = .left
                        
                        cell.taskFinishedButton.tag = indexPath.row
                        cell.taskFinishedButton.addTarget(self, action: #selector(self.finishTask), for: .touchUpInside)
                        
                        cell.taskDeadlineDate.isHidden = false
                        cell.taskInfo.isHidden = false
                        cell.taskFinishedButton.isHidden = false
                    } catch {
                        Postgres.logger.severe("Error in database communication: \(String(describing: error))")
                    }
                }
            } else {
                cell.videoTitle.text = "All Tasks Completed"
                cell.videoTitle.textColor = UIColor.black
                cell.videoTitle.numberOfLines = 0
                cell.videoTitle.font = UIFont.textStyle14
                cell.videoTitle.textAlignment = .left
                
                cell.taskDeadlineDate.isHidden = true
                cell.taskInfo.isHidden = true
                cell.taskFinishedButton.isHidden = true
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionCell", for: indexPath) as! CutomVideoCollectionCell
            
            if prodVideoSubset.count > 0 {
                let video = prodVideoSubset[indexPath.row]
                
                let dataString = video.thumbnail.first ?? ""
                let sliceOne = String(dataString.dropFirst())
                let sliceTwo = String(sliceOne.dropLast())
                let thumbnailData = Data(base64Encoded: sliceTwo)
                if let thumbnailData = thumbnailData {
                    cell.videoCellImage.image = UIImage(data: thumbnailData)
                }
                
                cell.videoCellTitle.text = video.title
                cell.videoCellTitle.textColor = UIColor.black
                cell.videoCellTitle.numberOfLines = 0
                cell.videoCellTitle.font = UIFont.textStyle2
                cell.videoCellTitle.textAlignment = .left
                
                cell.videoCellDate.date = video.filmdate.date(in: TimeZone.current)
                
                cell.videoCellDate.isHidden = false
                cell.videoCellImage.isHidden = false
            } else {
                cell.videoCellTitle.text = "No Videos in Production"
                cell.videoCellTitle.textColor = UIColor.black
                cell.videoCellTitle.numberOfLines = 0
                cell.videoCellTitle.font = UIFont.textStyle2
                cell.videoCellTitle.textAlignment = .left
                
                cell.videoCellDate.isHidden = true
                cell.videoCellImage.isHidden = true
            }
            
            return cell
        }
    }
    
//    func checkForPermission() {
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.getNotificationSettings { settings in
//            switch settings.authorizationStatus {
//            case .authorized:
//                self.dispatchNotification()
//            case .denied:
//                return
//            case .notDetermined:
//                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
//                    if didAllow {
//                        self.dispatchNotification()
//                    }
//                }
//            default:
//                return
//            }
//        }
//    }
    
//    func dispatchNotification() {
//        let identifier = "video-deadline-one-week"
//        let title = "Video Deadline Is Next Week"
//        let body = "[Video] has a [Stage] deadline in one week"
//
//        let notificationCenter = UNUserNotificationCenter.current()
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.body = body
//        content.sound = .default
//
//
//    }
}

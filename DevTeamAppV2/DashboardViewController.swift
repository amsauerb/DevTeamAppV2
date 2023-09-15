//
//  DashboardViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/30/23.
//

import PostgresClientKit
import UIKit

class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let model = DatabaseManager.shared.connectToDatabase()
    let currentUser = CurrentUser.shared
    var videoInformation = [Model.Video]()
    
    var postVideoSubset = [Model.Video]()
    var prodVideoSubset = [Model.Video]()
    
    @IBOutlet var welcomeField: UILabel!
    
    @IBOutlet var collectionViewProd: UICollectionView!
    @IBOutlet var collectionViewPost: UICollectionView!
    @IBOutlet var collectionViewTasks: UICollectionView!
    
    @IBOutlet var userButton: UIButton!
    @IBOutlet var taskButton: UIButton!
    @IBOutlet var videoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        collectionViewProd.dataSource = self
        collectionViewProd.delegate = self
        
        collectionViewPost.dataSource = self
        collectionViewPost.delegate = self
        
        collectionViewTasks.dataSource = self
        collectionViewTasks.delegate = self
        
        welcomeField.text = "Welcome " + currentUser.getCurrentUserName() + "!"
        
        if currentUser.getCurrentUserRole() == "Developer" {
            userButton.isHidden = true
            taskButton.isHidden = true
            videoButton.isHidden = true
        }
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
                self.collectionViewTasks.reloadData()
                
            } catch {
                Postgres.logger.severe("Error getting video list: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func userButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "createAccountView") as? CreateAccountViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func videoButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "videoManagerView") as? VideoManagerViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    @IBAction func taskButtonPressed() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "taskManagerView") as? TaskManagerViewController
        else {
            print("Button pressed failed")
            return
        }
        present(vc, animated:true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewProd {
            return prodVideoSubset.count
        } else if collectionView == collectionViewTasks {
            return 3
        }
        return postVideoSubset.count
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionViewPost {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionCell", for: indexPath) as! CutomVideoCollectionCell
            
            let video = postVideoSubset[indexPath.row]
            
            let dataString = video.thumbnail.first ?? ""
            let sliceOne = String(dataString.dropFirst())
            let sliceTwo = String(sliceOne.dropLast())
            let thumbnailData = Data(base64Encoded: sliceTwo)
            if let thumbnailData = thumbnailData {
                cell.videoCellImage.image = UIImage(data: thumbnailData)
            }
            
            cell.videoCellTitle.text = video.title
            cell.videoCellDate.date = video.postdate.date(in: TimeZone.current)
            cell.videoCellDate.tag = indexPath.row
            cell.videoCellDate.addTarget(self,
                                         action: #selector(updatePostDate),
                                         for: .valueChanged)
            
            return cell
        } else if collectionView == collectionViewTasks {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCollectionCell", for: indexPath) as! CustomTaskCollectionCell
            
            cell.taskDeadlineDate.date = Date()
            cell.taskInfo.text = "Testing the limits of how far this text will go."
            cell.videoTitle.text = "Example title"
            cell.taskFinishedSwitch.isOn = false
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionCell", for: indexPath) as! CutomVideoCollectionCell
            
            let video = prodVideoSubset[indexPath.row]
            
            let dataString = video.thumbnail.first ?? ""
            let sliceOne = String(dataString.dropFirst())
            let sliceTwo = String(sliceOne.dropLast())
            let thumbnailData = Data(base64Encoded: sliceTwo)
            if let thumbnailData = thumbnailData {
                cell.videoCellImage.image = UIImage(data: thumbnailData)
            }
            
            cell.videoCellTitle.text = video.title
            cell.videoCellDate.date = video.filmdate.date(in: TimeZone.current)
            
            return cell
        }
    }
}

//
//  DashboardViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/30/23.
//

import PostgresClientKit
import UIKit

class DashboardViewController: UIViewController {
    
    let model = DatabaseManager.shared.connectToDatabase()
    let currentUser = CurrentUser.shared
    var videoInformation = [Model.Video]()
    
    @IBOutlet var welcomeField: UILabel!
    
    @IBOutlet var postVideoOneImageField: UIImageView!
    @IBOutlet var postVideoTwoImageField: UIImageView!
    
    @IBOutlet var postVideoOneDateField: UIDatePicker!
    @IBOutlet var postVideoTwoDateField: UIDatePicker!
    
    @IBOutlet var postVideoOneTitleField: UILabel!
    @IBOutlet var postVideoTwoTitleField: UILabel!
    
    @IBOutlet var prodVideoOneImageField: UIImageView!
    @IBOutlet var prodVideoTwoImageField: UIImageView!
    @IBOutlet var prodVideoThreeImageField: UIImageView!
    @IBOutlet var prodVideoFourImageField: UIImageView!
    
    @IBOutlet var prodVideoOneDateField: UIDatePicker!
    @IBOutlet var prodVideoTwoDateField: UIDatePicker!
    @IBOutlet var prodVideoThreeDateField: UIDatePicker!
    @IBOutlet var prodVideoFourDateField: UIDatePicker!
    
    @IBOutlet var prodVideoOneTitleField: UILabel!
    @IBOutlet var prodVideoTwoTitleField: UILabel!
    @IBOutlet var prodVideoThreeTitleField: UILabel!
    @IBOutlet var prodVideoFourTitleField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeField.text = "Welcome " + currentUser.getCurrentUserName() + "!"
        
        model.getAllVideos() { result in
            do {
                self.videoInformation = try result.get()
                let postVideoSubset = self.videoInformation.filter {$0.currentstage == "Polish" || $0.currentstage == "Filmed"}
                let prodVideoSubset = self.videoInformation.filter {$0.currentstage != "Polish" || $0.currentstage != "Filmed"}
                
                self.postVideoOneTitleField.text = postVideoSubset.first?.title ?? ""
                self.postVideoOneDateField.date = postVideoSubset.first?.postdate.date(in: TimeZone.current) ?? Date()
                
                var dataString = postVideoSubset.first?.thumbnail.first ?? ""
                var sliceOne = String(dataString.dropFirst())
                var sliceTwo = String(sliceOne.dropLast())
                var thumbnailData = Data(base64Encoded: sliceTwo)
                if let thumbnailData = thumbnailData {
                    self.postVideoOneImageField.image = UIImage(data: thumbnailData)
                }
                
                self.postVideoTwoTitleField.text = postVideoSubset[1].title
                self.postVideoTwoDateField.date = postVideoSubset[1].postdate.date(in: TimeZone.current)
                
                dataString = postVideoSubset[1].thumbnail.first ?? ""
                sliceOne = String(dataString.dropFirst())
                sliceTwo = String(sliceOne.dropLast())
                thumbnailData = Data(base64Encoded: sliceTwo)
                if let thumbnailData = thumbnailData {
                    self.postVideoTwoImageField.image = UIImage(data: thumbnailData)
                }
                
                self.prodVideoOneTitleField.text = prodVideoSubset[0].title
                self.prodVideoOneDateField.date = prodVideoSubset[0].filmdate.date(in: TimeZone.current)
                
                dataString = prodVideoSubset[0].thumbnail.first ?? ""
                sliceOne = String(dataString.dropFirst())
                sliceTwo = String(sliceOne.dropLast())
                thumbnailData = Data(base64Encoded: sliceTwo)
                if let thumbnailData = thumbnailData {
                    self.prodVideoOneImageField.image = UIImage(data: thumbnailData)
                }
                
                self.prodVideoTwoTitleField.text = prodVideoSubset[1].title
                self.prodVideoTwoDateField.date = prodVideoSubset[1].filmdate.date(in: TimeZone.current)
                
                dataString = prodVideoSubset[1].thumbnail.first ?? ""
                sliceOne = String(dataString.dropFirst())
                sliceTwo = String(sliceOne.dropLast())
                thumbnailData = Data(base64Encoded: sliceTwo)
                if let thumbnailData = thumbnailData {
                    self.prodVideoTwoImageField.image = UIImage(data: thumbnailData)
                }
                
                self.prodVideoThreeTitleField.text = prodVideoSubset[2].title
                self.prodVideoThreeDateField.date = prodVideoSubset[2].filmdate.date(in: TimeZone.current)
                
                dataString = prodVideoSubset[2].thumbnail.first ?? ""
                sliceOne = String(dataString.dropFirst())
                sliceTwo = String(sliceOne.dropLast())
                thumbnailData = Data(base64Encoded: sliceTwo)
                if let thumbnailData = thumbnailData {
                    self.prodVideoThreeImageField.image = UIImage(data: thumbnailData)
                }
                
                self.prodVideoFourTitleField.text = prodVideoSubset[3].title
                self.prodVideoFourDateField.date = prodVideoSubset[3].filmdate.date(in: TimeZone.current)
                
                dataString = prodVideoSubset[3].thumbnail.first ?? ""
                sliceOne = String(dataString.dropFirst())
                sliceTwo = String(sliceOne.dropLast())
                thumbnailData = Data(base64Encoded: sliceTwo)
                if let thumbnailData = thumbnailData {
                    self.prodVideoFourImageField.image = UIImage(data: thumbnailData)
                }
                
            } catch {
                Postgres.logger.severe("Error getting video list: \(String(describing: error))")
            }
        }
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

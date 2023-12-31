//
//  VideoReviewViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/29/23.
//

import PostgresClientKit
import UIKit

class VideoReviewViewController: UIViewController {
    
    var Model: Model!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
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
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "dashboardView") as? DashboardViewController
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

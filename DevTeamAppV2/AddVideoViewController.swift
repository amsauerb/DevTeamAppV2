//
//  AddVideoViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/29/23.
//

import PostgresClientKit
import UIKit
import Foundation

class AddVideoViewController: UIViewController {
    
    let model = DatabaseManager.shared.connectToDatabase()
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var filmdateField: UIDatePicker!
    @IBOutlet var budgetCompleteField: UISwitch!
    @IBOutlet var prepreField: UITextField!
    @IBOutlet var directorsnotesField: UITextField!
    @IBOutlet var productionnotesField: UITextField!
    @IBOutlet var shotlistField: UITextField!
    @IBOutlet var constructionnotesField: UITextField!
    @IBOutlet var leadproducerField: UITextField!
    @IBOutlet var leaddirectorField: UITextField!
    @IBOutlet var thumbnailField: UIImageView!
    
    @IBOutlet var createVideoButton: UIButton!
    @IBOutlet var errorView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createVideoButton.isUserInteractionEnabled = false
        errorView.text = ""
        errorView.isUserInteractionEnabled = false
        
        view.backgroundColor = .link
    }
    
    @IBAction func requiredFieldsFilled() {
        if titleField.text == "" {
            createVideoButton.isUserInteractionEnabled = false
        } else {
            createVideoButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func thumbnailButtonPressed() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated:true)
    }
    
    @IBAction func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createVideoButtonPressed() {
        view.endEditing(true)
        let title = titleField.text?.trimmingCharacters(in: [" "]) ?? ""
        let prepredoc = prepreField.text?.trimmingCharacters(in: [" "]) ?? ""
        let constructionnotesdoc = constructionnotesField.text?.trimmingCharacters(in: [" "]) ?? ""
        let productionnotesdoc = productionnotesField.text?.trimmingCharacters(in: [" "]) ?? ""
        let shotlistdoc = shotlistField.text?.trimmingCharacters(in: [" "]) ?? ""
        let directorsnotesdoc = directorsnotesField.text?.trimmingCharacters(in: [" "]) ?? ""
        let leadproducer = leadproducerField.text?.trimmingCharacters(in: [" "]) ?? ""
        let leaddirector = leaddirectorField.text?.trimmingCharacters(in: [" "]) ?? ""
        
        let budgetcomplete = budgetCompleteField.isOn
        
        let filmdate = PostgresDate(date: filmdateField.date, in: TimeZone.current)
        let thumbnail = thumbnailField.image?.jpegData(compressionQuality: 1)
        let thumbnailstring = thumbnail?.base64EncodedString() ?? ""
        
        model.createVideo(title, filmdate: filmdate, budgetcomplete: budgetcomplete, prepredoc: prepredoc, directorsnotesdoc: directorsnotesdoc, productionnotesdoc: productionnotesdoc, shotlistdoc: shotlistdoc, constructionnotesdoc: constructionnotesdoc, leadproducer: leadproducer, leaddirector: leaddirector, thumbnail: thumbnailstring) { result in
            do {
                self.videoInformation = try result.get()
                Postgres.logger.fine("Length of video list: " + String(self.videoInformation.count))
                if self.videoInformation.count < 1 {
                    self.errorView.text = "The video wasn't created correctly"
                } else if title == self.videoInformation.first?.title {
                    self.errorView.text = "The video was created successfully"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    Postgres.logger.fine("Video Creation Failed")
                }
            } catch {
                // Better error handling goes here...
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    var videoInformation = [Model.Video]()
}

extension AddVideoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            thumbnailField.image = image
        }
        
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//
//  AddVideoViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/29/23.
//

import PostgresClientKit
import UIKit
import Foundation
import Amplify


class AddVideoViewController: UIViewController {
    
    let model = DatabaseManager.shared.connectToDatabase()
    let currentUser = CurrentUser.shared
    
    var budgetComplete = false
    
    @IBOutlet var welcomeField: UILabel!
    @IBOutlet var userThumbnail: UIImageView!
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var filmdateField: UIDatePicker!
    @IBOutlet var budgetCompleteField: UIButton!
    @IBOutlet var prepreField: UITextField!
    @IBOutlet var directorsnotesField: UITextField!
    @IBOutlet var productionnotesField: UITextField!
    @IBOutlet var shotlistField: UITextField!
    @IBOutlet var constructionnotesField: UITextField!
    @IBOutlet var thumbnailField: UIImageView!
    
    @IBOutlet var budgetRectangle: UIView!
    @IBOutlet var scrollView: UIView!
    
    @IBOutlet var createVideoButton: UIButton!
    @IBOutlet var errorView: UITextView!
    
    @IBOutlet var directorMenu: UIButton!
    @IBOutlet var producerMenu: UIButton!
    
    @IBOutlet var chooseThumbnailButton: UIButton!
    
    @IBOutlet var startDateField: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        loadPrettyViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        createVideoButton.isUserInteractionEnabled = false
        errorView.text = ""
        errorView.isUserInteractionEnabled = false
        
        setDirectorButton()
        setProducerButton()
        
        titleField.text = ""
        filmdateField.date = Date()
        startDateField.date = Date()
        prepreField.text = ""
        directorsnotesField.text = ""
        productionnotesField.text = ""
        shotlistField.text = ""
        constructionnotesField.text = ""
        thumbnailField.image = UIImage()
    }
    
    func loadPrettyViews() {
        self.view.backgroundColor = UIColor.daisy
        scrollView.backgroundColor = UIColor.daisy

        welcomeField.layer.opacity = 1
        welcomeField.textColor = UIColor.black
        welcomeField.numberOfLines = 0
        welcomeField.font = UIFont.textStyle2
        welcomeField.textAlignment = .left
        welcomeField.text = currentUser.getCurrentUserName()
        
        chooseThumbnailButton.layer.cornerRadius = 5
        chooseThumbnailButton.layer.masksToBounds = true
        
        userThumbnail.layer.cornerRadius = 10
        userThumbnail.layer.borderWidth = 1
        userThumbnail.layer.borderColor = UIColor.black.cgColor
        
        prepreField.backgroundColor = UIColor.daisy
        prepreField.textColor = UIColor.black
        prepreField.layer.cornerRadius = 10
        prepreField.layer.masksToBounds =  true
        prepreField.layer.borderColor = UIColor.black.cgColor
        prepreField.layer.borderWidth =  1
        
        directorsnotesField.backgroundColor = UIColor.daisy
        directorsnotesField.textColor = UIColor.black
        directorsnotesField.layer.cornerRadius = 10
        directorsnotesField.layer.masksToBounds =  true
        directorsnotesField.layer.borderColor = UIColor.black.cgColor
        directorsnotesField.layer.borderWidth =  1
        
        shotlistField.backgroundColor = UIColor.daisy
        shotlistField.textColor = UIColor.black
        shotlistField.layer.cornerRadius = 10
        shotlistField.layer.masksToBounds =  true
        shotlistField.layer.borderColor = UIColor.black.cgColor
        shotlistField.layer.borderWidth =  1
        
        constructionnotesField.backgroundColor = UIColor.daisy
        constructionnotesField.textColor = UIColor.black
        constructionnotesField.layer.cornerRadius = 10
        constructionnotesField.layer.masksToBounds =  true
        constructionnotesField.layer.borderColor = UIColor.black.cgColor
        constructionnotesField.layer.borderWidth =  1

        productionnotesField.backgroundColor = UIColor.daisy
        productionnotesField.textColor = UIColor.black
        productionnotesField.layer.cornerRadius = 10
        productionnotesField.layer.masksToBounds =  true
        productionnotesField.layer.borderColor = UIColor.black.cgColor
        productionnotesField.layer.borderWidth =  1

        titleField.backgroundColor = UIColor.daisy
        titleField.textColor = UIColor.black
        titleField.layer.cornerRadius = 10
        titleField.layer.masksToBounds =  true
        titleField.layer.borderColor = UIColor.black.cgColor
        titleField.layer.borderWidth =  1
        
        errorView.backgroundColor = UIColor.daisy
        errorView.textColor = UIColor.black

//        addNewVideoLabel.layer.opacity = 1
//        addNewVideoLabel.textColor = UIColor.black
//        addNewVideoLabel.numberOfLines = 0
//        addNewVideoLabel.font = UIFont.textStyle8
//        addNewVideoLabel.textAlignment = .left
//        addNewVideoLabel.text = NSLocalizedString("add.new.video", comment: "")
//
//
//        leadProducerLabel.layer.opacity = 1
//        leadProducerLabel.textColor = UIColor.black
//        leadProducerLabel.numberOfLines = 0
//        leadProducerLabel.font = UIFont.textStyle12
//        leadProducerLabel.textAlignment = .left
//        leadProducerLabel.text = NSLocalizedString("lead.producer", comment: "")


        producerMenu.layer.cornerRadius = 6
        producerMenu.layer.masksToBounds =  true
        producerMenu.backgroundColor = UIColor.salt2
        producerMenu.layer.opacity = 1
        producerMenu.setTitleColor(UIColor.black, for: .normal)
        producerMenu.titleLabel?.font = UIFont.textStyle12
        producerMenu.contentHorizontalAlignment = .leading


//        leadDirectorLabel.layer.opacity = 1
//        leadDirectorLabel.textColor = UIColor.black
//        leadDirectorLabel.numberOfLines = 0
//        leadDirectorLabel.font = UIFont.textStyle12
//        leadDirectorLabel.textAlignment = .left
//        leadDirectorLabel.text = NSLocalizedString("lead.director", comment: "")


        directorMenu.layer.cornerRadius = 6
        directorMenu.layer.masksToBounds =  true
        directorMenu.backgroundColor = UIColor.salt2
        directorMenu.layer.opacity = 1
        directorMenu.setTitleColor(UIColor.black, for: .normal)
        directorMenu.titleLabel?.font = UIFont.textStyle12
        directorMenu.contentHorizontalAlignment = .leading


        thumbnailField.layer.cornerRadius = 21
        thumbnailField.layer.masksToBounds =  true
        thumbnailField.backgroundColor = UIColor.salt4
        thumbnailField.layer.opacity = 1


//        titleLabel.layer.opacity = 1
//        titleLabel.textColor = UIColor.slate
//        titleLabel.numberOfLines = 0
//        titleLabel.font = UIFont.textStyle
//        titleLabel.textAlignment = .left
//        titleLabel.text = NSLocalizedString("title", comment: "")


        startDateField.layer.opacity = 1


        filmdateField.layer.opacity = 1


        budgetRectangle.backgroundColor = UIColor.daisy
        budgetRectangle.layer.opacity = 1
        
        budgetRectangle.layer.masksToBounds = false
        budgetRectangle.layer.shadowColor = UIColor.black.cgColor
        budgetRectangle.layer.shadowOpacity = 0.7
        budgetRectangle.layer.shadowOffset = CGSize(width: 3, height: 3)
        budgetRectangle.layer.shadowRadius = 3


//        budgetCompletedLabel.layer.opacity = 1
//        budgetCompletedLabel.textColor = UIColor.black
//        budgetCompletedLabel.numberOfLines = 0
//        budgetCompletedLabel.font = UIFont.textStyle6
//        budgetCompletedLabel.textAlignment = .left
//        budgetCompletedLabel.text = NSLocalizedString("budget.completed", comment: "")

        let origImage = UIImage(named: "frame3")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        budgetCompleteField.setImage(tintedImage, for: .normal)
        budgetCompleteField.tintColor = .red


//        prepreLabel.layer.opacity = 1
//        prepreLabel.textColor = UIColor.slate
//        prepreLabel.numberOfLines = 0
//        prepreLabel.font = UIFont.Undefined_Text_Font
//        prepreLabel.textAlignment = .left
//        prepreLabel.text = NSLocalizedString("pre.pre", comment: "")
//
//
//        productionNotesLabel.layer.opacity = 1
//        productionNotesLabel.textColor = UIColor.slate
//        productionNotesLabel.numberOfLines = 0
//        productionNotesLabel.font = UIFont.Undefined_Text_Font
//        productionNotesLabel.textAlignment = .left
//        productionNotesLabel.text = NSLocalizedString("production.notes", comment: "")
//
//
//        shotListLabel.layer.opacity = 1
//        shotListLabel.textColor = UIColor.slate
//        shotListLabel.numberOfLines = 0
//        shotListLabel.font = UIFont.Undefined_Text_Font
//        shotListLabel.textAlignment = .left
//        shotListLabel.text = NSLocalizedString("shot.list", comment: "")
    }
    
    func setDirectorButton() {
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
        directorMenu.menu = UIMenu(children: [
            UIAction(title : "Kyle", state: .on, handler: optionClosure),
            UIAction(title : "Drew", handler: optionClosure),
            UIAction(title : "Sean", handler: optionClosure)])
        
        directorMenu.showsMenuAsPrimaryAction = true
        directorMenu.changesSelectionAsPrimaryAction = true
    }
    
    func setProducerButton() {
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
        producerMenu.menu = UIMenu(children: [
            UIAction(title : "Dustin", state: .on, handler: optionClosure),
            UIAction(title : "Will", handler: optionClosure),
            UIAction(title : "Mike", handler: optionClosure),
            UIAction(title : "Rachel", handler: optionClosure),
                UIAction(title: "Locoya", handler: optionClosure)])
        
        producerMenu.showsMenuAsPrimaryAction = true
        producerMenu.changesSelectionAsPrimaryAction = true
    }
//
//    func uploadImage() async {
//        let image = thumbnailField.image
//        let imageData = (image?.jpegData(compressionQuality: 1))!
//        let imageKey = titleField.text! + "-thumbnail"
//
//        let uploadTask = Amplify.Storage.uploadData(key: imageKey, data: imageData)
//        Task {
//            for await progress in await uploadTask.progress {
//                print("Progress: \(progress)")
//            }
//        }
//        let value = try await uploadTask.value
//        print("Completed: \(value)")
//    }
    
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
    
    @IBAction func budgetButtonPressed() {
        if budgetComplete {
            budgetComplete = false
            let origImage = UIImage(named: "frame3")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            budgetCompleteField.setImage(tintedImage, for: .normal)
            budgetCompleteField.tintColor = .red
        } else {
            budgetComplete = true
            budgetCompleteField.setImage(UIImage(named: "frame3") , for: .normal)
            budgetCompleteField.tintColor = .green
        }
    }
    
    @IBAction func createVideoButtonPressed() {
        view.endEditing(true)
        let title = titleField.text?.trimmingCharacters(in: [" "]) ?? ""
        let prepredoc = prepreField.text?.trimmingCharacters(in: [" "]) ?? ""
        let constructionnotesdoc = constructionnotesField.text?.trimmingCharacters(in: [" "]) ?? ""
        let productionnotesdoc = productionnotesField.text?.trimmingCharacters(in: [" "]) ?? ""
        let shotlistdoc = shotlistField.text?.trimmingCharacters(in: [" "]) ?? ""
        let directorsnotesdoc = directorsnotesField.text?.trimmingCharacters(in: [" "]) ?? ""
        let leadproducer = producerMenu.menu?.selectedElements.first?.title ?? ""
        let leaddirector = directorMenu.menu?.selectedElements.first?.title ?? ""
        
        let filmdate = PostgresDate(date: filmdateField.date, in: TimeZone.current)
        let post = Calendar.current.date(byAdding: .day, value: 30, to: filmdateField.date)
        let postdate = PostgresDate(date: post ?? filmdateField.date, in: TimeZone.current)
        
        let thumbnail = thumbnailField.image?.jpegData(compressionQuality: 1)
        let thumbnailstring = thumbnail?.base64EncodedString() ?? ""
        
        
        
        
        
//        let date = Date()
        let diffInDays = Calendar.current.dateComponents([.day], from: filmdateField.date, to: startDateField.date).day ?? 90
        
        var videoProductionType = ""
        
        if diffInDays > 30 {
            videoProductionType = "Sixty"
        } else if diffInDays > 60 {
            videoProductionType = "Ninety"
        } else {
            videoProductionType = "Thirty"
        }
        
        let macroDeadline = Calendar.current.date(byAdding: .day, value: -30, to: filmdateField.date)
        let microDeadline = Calendar.current.date(byAdding: .day, value: -14, to: filmdateField.date)
        
        var frameworkDeadline = Date()
        
        if videoProductionType == "Thirty" {
            frameworkDeadline = Calendar.current.date(byAdding: .day, value: -30, to: filmdateField.date)!
        } else if videoProductionType == "Sixty" {
            frameworkDeadline = Calendar.current.date(byAdding: .day, value: -53, to: filmdateField.date)!
        } else {
            frameworkDeadline = Calendar.current.date(byAdding: .day, value: -76, to: filmdateField.date)!
        }
        
        let productiontype = videoProductionType
        
        model.createVideo(title, filmdate: filmdate, budgetcomplete: self.budgetComplete, prepredoc: prepredoc, directorsnotesdoc: directorsnotesdoc, productionnotesdoc: productionnotesdoc, shotlistdoc: shotlistdoc, constructionnotesdoc: constructionnotesdoc, leadproducer: leadproducer, leaddirector: leaddirector, thumbnail: thumbnailstring, productiontype: productiontype, postdate: postdate, startdate: startDateField.date.postgresDate(in: TimeZone.current), frameworkdate: frameworkDeadline.postgresDate(in: TimeZone.current), macrodate: (macroDeadline?.postgresDate(in: TimeZone.current))!, microdate: (microDeadline?.postgresDate(in: TimeZone.current))!) { result in
            do {
                self.videoInformation = try result.get()
                Postgres.logger.fine("Length of video list: " + String(self.videoInformation.count))
                if self.videoInformation.count < 1 {
                    self.errorView.text = "The video wasn't created correctly"
                } else if title == self.videoInformation.first?.title {
                    self.errorView.text = "The video was created successfully"
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

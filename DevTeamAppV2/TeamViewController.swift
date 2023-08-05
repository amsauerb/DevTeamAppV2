//
//  TeamViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 7/29/23.
//

import PostgresClientKit
import UIKit

class TeamViewController: UIViewController, UITableViewDataSource {
    
    let model = DatabaseManager.shared.connectToDatabase()
    
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
        directorMenu.layer.borderWidth = 1
        directorMenu.layer.borderColor = UIColor.lightGray.cgColor
        
        setProducerButton()
        producerMenu.layer.borderWidth = 1
        producerMenu.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setDirectorButton() {
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        
        directorMenu.menu = UIMenu(children: [
            UIAction(title : "Dustin", state: .on, handler: optionClosure),
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
            UIAction(title : "Kyle", state: .on, handler: optionClosure),
            UIAction(title : "Drew", handler: optionClosure),
            UIAction(title : "Sean", handler: optionClosure)])
        
        producerMenu.showsMenuAsPrimaryAction = true
        producerMenu.changesSelectionAsPrimaryAction = true
    }
    
    @IBAction func showButtonPressed() {
        view.endEditing(true)
        let director = directorMenu.menu?.selectedElements.first?.title ?? ""
        let producer = producerMenu.menu?.selectedElements.first?.title ?? ""
        
        model.videoListByDirectorProducer(producer, director: director) { result in
            do {
                self.videoInformation = try result.get()
                if self.videoInformation.count > 0 {
                    self.errorView.text = "Videos for: " + director + " and " + producer
                } else {
                    self.errorView.text = "No videos found"
                }
                self.tableView.reloadData()
            } catch {
                Postgres.logger.severe("Error getting video list: \(String(describing: error))")
            }
            
        }
    }
    
    var videoInformation = [Model.Video]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "VideoCell")
        
        let video = videoInformation[indexPath.row]
        let text = String(describing: video.title)
        var detailText = "Days Until Filming: 0"
        
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detailText
        
        return cell
    }
}

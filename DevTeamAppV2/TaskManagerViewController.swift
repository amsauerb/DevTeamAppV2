//
//  TaskManagerViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 9/5/23.
//

import PostgresClientKit
import UIKit
import Foundation

class TaskManagerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    let model = DatabaseManager.shared.connectToDatabase()
    let currentUser = CurrentUser.shared
    
    var taskInformation = [Model.Task]()
    var selectedTask = [Model.Task]()
    
    var userInformation = [Model.User]()
    var selectedUsers = [Model.User]()
    var selectedUsersReset = false
    
    var usersForTask = [Model.UserTask]()
    
    var format = DateFormatter()
    
    @IBOutlet var welcomeField: UILabel!
    @IBOutlet var userThumbnail: UIImageView!
    @IBOutlet var taskNameField: UITextField!
    @IBOutlet var taskDescriptionField: UITextView!
    @IBOutlet var userMenu: UIButton!
    @IBOutlet var assignedUsersCollection: UICollectionView!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var userButton: UIButton!
    @IBOutlet var taskButton: UIButton!
    @IBOutlet var videoButton: UIButton!
    @IBOutlet var dashboardButton: UIButton!
    @IBOutlet var taskDeadline: UIDatePicker!
    @IBOutlet var taskTable: UITableView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var dateLabel: UILabel!
    
    var del: TaskManagerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        taskNameField.placeholder = "Task Name"
        taskDescriptionField.text = "Description"
        
        assignedUsersCollection.dataSource = self
        assignedUsersCollection.delegate = self
        
        taskTable.dataSource = self
        taskTable.delegate = self
        
        model.getAllTasks() { result in
            do {
                self.taskInformation = try result.get()
                self.taskTable.reloadData()
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
            self.setUserMenu()
        }
        
        assignedUsersCollection.reloadData()
        
        format.dateFormat = "MMM d, y"
        taskDeadline.addTarget(self, action: #selector(updateDateLabel), for: .valueChanged)
        
        loadPrettyViews()
    }
    
    func loadPrettyViews() {
        self.view.backgroundColor = UIColor.daisy
        
        welcomeField.layer.opacity = 1
        welcomeField.textColor = UIColor.black
        welcomeField.numberOfLines = 0
        welcomeField.font = UIFont.textStyle2
        welcomeField.textAlignment = .left
        welcomeField.text = currentUser.getCurrentUserName()
        
        videoButton.layer.cornerRadius = 7
        videoButton.layer.masksToBounds =  true
        videoButton.backgroundColor = UIColor.salt2
        videoButton.layer.opacity = 1
        videoButton.setTitleColor(UIColor.black, for: .normal)
        videoButton.titleLabel?.font = UIFont.textStyle9
        videoButton.contentHorizontalAlignment = .leading
        
        userButton.layer.cornerRadius = 7
        userButton.layer.masksToBounds =  true
        userButton.backgroundColor = UIColor.salt2
        userButton.layer.opacity = 1
        userButton.setTitleColor(UIColor.black, for: .normal)
        userButton.titleLabel?.font = UIFont.textStyle9
        userButton.contentHorizontalAlignment = .leading
        
        taskButton.layer.cornerRadius = 7
        taskButton.layer.masksToBounds =  true
        taskButton.backgroundColor = UIColor.black
        taskButton.layer.opacity = 1
        taskButton.setTitleColor(UIColor.daisy, for: .normal)
        taskButton.titleLabel?.font = UIFont.textStyle9
        taskButton.contentHorizontalAlignment = .leading
        
//        dashboardButton.layer.cornerRadius = 7
//        dashboardButton.layer.masksToBounds =  true
//        dashboardButton.layer.borderColor = UIColor.sapphire.cgColor
//        dashboardButton.layer.borderWidth =  2
//        dashboardButton.layer.opacity = 1
//        dashboardButton.setTitleColor(UIColor.sapphire, for: .normal)
//        dashboardButton.titleLabel?.font = UIFont.textStyle9
//        dashboardButton.contentHorizontalAlignment = .leading
        
        createButton.layer.cornerRadius = 7
        createButton.layer.masksToBounds = true
        createButton.layer.borderColor = UIColor.sapphire.cgColor
        createButton.layer.borderWidth = 2
        createButton.setTitleColor(UIColor.sapphire, for: .normal)
        
        containerView.backgroundColor = UIColor.daisy
        containerView.layer.opacity = 1
        
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.7
        containerView.layer.shadowOffset = CGSize(width: 3, height: 3)
        containerView.layer.shadowRadius = 3
        
        userThumbnail.layer.cornerRadius = 10
        userThumbnail.layer.borderWidth = 1
        userThumbnail.layer.borderColor = UIColor.black.cgColor
        
        taskDeadline.preferredDatePickerStyle = UIDatePickerStyle.compact
        taskDeadline.addTarget(self, action: #selector(updateDateLabel), for: .valueChanged)
        
        dateLabel.layer.cornerRadius = 5
        dateLabel.layer.masksToBounds = true
    }
    
    @objc func updateDateLabel(sender: UIDatePicker) {
        dateLabel.text = format.string(from: sender.date)
    }
    
    func loadTaskTable() {
        model.getAllTasks() { result in
            do {
                self.taskInformation = try result.get()
                self.taskTable.reloadData()
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    func reloadAssignedUserCollection() {
        assignedUsersCollection.reloadData()
    }
    
    func setUserMenu() {
        let optionClosure = {(action: UIAction) in self.getUserInfo()}
        
        model.getAllUsers() { result in
            do {
                self.userInformation = try result.get()
                
                var children: [UIMenuElement] = []
                
                let a = UIAction(title: "Assign", state: .on, handler: optionClosure)
                children.append(a)
                
                for user in self.userInformation {
                    let action = UIAction(title: user.name, handler: optionClosure)
                    children.append(action)
                }
                self.userMenu.menu = UIMenu(children: children)
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
        
        userMenu.showsMenuAsPrimaryAction = true
        userMenu.changesSelectionAsPrimaryAction = true
    }
    
    func getUserInfo() {
        let name = userMenu.menu?.selectedElements.first?.title ?? ""
        
        if !selectedUsersReset {
            selectedUsers.removeAll()
            selectedUsersReset = true
        }
        
        if name != "" {
            model.userByName(name) { result in
                do {
                    let user = try result.get()
                    Postgres.logger.fine(user.first?.name ?? "Something went wrong")
                    if self.selectedUsers.contains(where: { $0.name == user.first?.name }) {
                        self.selectedUsers.removeAll {$0.name == user.first?.name}
                        self.reloadAssignedUserCollection()
                    } else {
                        self.selectedUsers.append(contentsOf: user)
                        self.reloadAssignedUserCollection()
                    }
                    
                    self.setUserMenu()
                } catch {
                    Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let result = (selectedUsers.count != 0) ? selectedUsers.count : 1
        return result
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "assignedImageCell", for: indexPath) as! CustomAssignedUserCell
        
        if selectedUsers.count != 0 {
            cell.assignedUserImage.image = UIImage(named: "frame3")
        } else {
            cell.assignedUserImage.image = UIImage()
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result = (taskInformation.count != 0) ? taskInformation.count : 1
        return result
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") {_, _, _ in
            let tid = self.taskInformation[indexPath.row].tid
            
            self.model.deleteTask(tid) { result in
                do {
                    let task = try result.get()
                    if task.first!.tid == tid {
                        self.taskNameField.placeholder = "Task Name"
                        self.taskDeadline.date = Date()
                        self.taskDescriptionField.text = "Description"
                        
                        self.taskTable.beginUpdates()
                        self.model.getAllTasks() { result in
                            do {
                                self.taskInformation = try result.get()
                                self.taskTable.deleteRows(at: [indexPath], with: .fade)
                                self.taskTable.endUpdates()
                            } catch {
                                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                            }
                        }
                        
                        self.setUserMenu()
                        
                        self.selectedTask.removeAll()
                        self.selectedUsers.removeAll()
                        self.usersForTask.removeAll()
                        
                        self.assignedUsersCollection.reloadData()
                    }
                } catch {
                    Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                }
            }
        }
        
        delete.image = UIImage(named: "vector7")
        
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        swipe.performsFirstActionWithFullSwipe = false
        return swipe
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = UIContextualAction(style: .destructive, title: "Complete") {_, _, _ in
            let tid = self.taskInformation[indexPath.row].tid
            
            self.model.deleteTask(tid) { result in
                do {
                    let task = try result.get()
                    if task.first!.tid == tid {
                        self.taskNameField.placeholder = "Task Name"
                        self.taskDeadline.date = Date()
                        self.taskDescriptionField.text = "Description"
                        
                        self.taskTable.beginUpdates()
                        self.model.getAllTasks() { result in
                            do {
                                self.taskInformation = try result.get()
                                self.taskTable.deleteRows(at: [indexPath], with: .fade)
                                self.taskTable.endUpdates()
                            } catch {
                                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                            }
                        }
                        
                        self.setUserMenu()
                        
                        self.selectedTask.removeAll()
                        self.selectedUsers.removeAll()
                        self.usersForTask.removeAll()
                        
                        self.assignedUsersCollection.reloadData()
                    }
                } catch {
                    Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                }
            }
        }
        
        complete.image = UIImage(named: "frame3")
        complete.backgroundColor = .green
        
        let swipe = UISwipeActionsConfiguration(actions: [complete])
        swipe.performsFirstActionWithFullSwipe = false
        return swipe
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = taskTable.dequeueReusableCell(withIdentifier: "taskTableCell", for: indexPath) as! CustomTaskTableCell
        
        if taskInformation.count == 0 {
            cell.taskName.text = "No tasks currently!"
        } else {
            let task = taskInformation[indexPath.row]
            selectedTask.removeAll()
            selectedUsers.removeAll()
            usersForTask.removeAll()
            
            cell.taskName.text = task.title
            cell.taskDescription.text = task.description
            cell.taskDeadline.date = task.deadline.date(in: TimeZone.current)
            
            cell.assignedCollection.delegate = self
            cell.assignedCollection.dataSource = self

            model.getAllUsersForTID(task.tid) { result in
                do {
                    self.usersForTask = try result.get()

                    for userTask in self.usersForTask {
                        let uid = userTask.id
                        self.model.userByID(uid) { result in
                            do {
                                let user = try result.get()
                                self.selectedUsers.append(contentsOf: user)
                                cell.assignedCollection.reloadData()
                            } catch {
                                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                            }
                        }
                    }
                } catch {
                    Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                }
            }
            
            cell.editButton.tag = indexPath.row
            cell.editButton.addTarget(self, action: #selector(self.editTask), for: .touchUpInside)
        }
        
        cell.container.backgroundColor = UIColor.daisy
        cell.container.layer.opacity = 1
        
        cell.container.layer.masksToBounds = false
        cell.container.layer.shadowColor = UIColor.black.cgColor
        cell.container.layer.shadowOpacity = 0.7
        cell.container.layer.shadowOffset = CGSize(width: 3, height: 3)
        cell.container.layer.shadowRadius = 3
        
        return cell
    }
    
    @objc func editTask(sender: UIButton) {
        let path = IndexPath(row: sender.tag, section: 0)
        let task = self.taskInformation[path.row]
        selectedTask.removeAll()
        selectedUsers.removeAll()
        usersForTask.removeAll()
        
        selectedTask.append(task)
        
        self.taskNameField.text = task.title
        self.taskDescriptionField.text = task.description
        self.taskDeadline.date = task.deadline.date(in: TimeZone.current)
        self.dateLabel.text = self.format.string(from: self.taskDeadline.date)
        
        model.getAllUsersForTID(task.tid) { result in
            do {
                self.usersForTask = try result.get()
                
                for userTask in self.usersForTask {
                    let uid = userTask.id
                    self.model.userByID(uid) { result in
                        do {
                            let user = try result.get()
                            self.selectedUsers.append(contentsOf: user)
                            self.assignedUsersCollection.reloadData()
                        } catch {
                            Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                        }
                    }
                }
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func createTask() {
        let title = taskNameField.text!
        let deadline = taskDeadline.date
        let description = taskDescriptionField.text!
        
        var tid = 0
        
        model.addTask(title, description: description, deadline: deadline.postgresDate(in: TimeZone.current)) { result in
            do {
                let task = try result.get()
                if task.first!.title == title {
                    tid = task.first!.tid
                    self.createUserTasks(tid: tid)
                }
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    func createUserTasks(tid: Int) {
        for user in selectedUsers {
            let uid = user.id
            Postgres.logger.fine(String(uid))
            
            model.addUserTask(tid, id: uid) { result in
                do {
                    let userTask = try result.get()
                } catch {
                    Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.taskNameField.placeholder = "Task Name"
            self.taskNameField.text = ""
            self.taskDeadline.date = Date()
            self.taskDescriptionField.text = "Description"
            self.setUserMenu()
            
            self.selectedTask.removeAll()
            self.selectedUsers.removeAll()
            self.usersForTask.removeAll()
            
            self.assignedUsersCollection.reloadData()
            self.loadTaskTable()
            self.selectedUsersReset = false
        }
        
        
    }
    
    @IBAction func updateTask() {
        let title = taskNameField.text!
        let deadline = taskDeadline.date
        let description = taskDescriptionField.text!
        
        let tid = selectedTask.first!.tid
        
        model.updateTask(tid, title: title, description: description, deadline: deadline.postgresDate(in: TimeZone.current)) { result in
            do {
                let task = try result.get()
                if task.first!.title == title {
                    //
                }
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
        
        for usertask in usersForTask {
            let uid = usertask.id
            var deleteUserTask = true
            for user in selectedUsers {
                if user.id == uid {
                    deleteUserTask = false
                }
            }
            
            if deleteUserTask {
                model.deleteUserTask(tid, id: uid) { result in
                    do {
                        let uT = try result.get()
                        //
                    } catch {
                        Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                    }
                }
            }
        }
        
        for user in selectedUsers {
            let uid = user.id
            var addUser = true
            for usertask in usersForTask {
                if usertask.id == uid {
                    addUser = false
                }
            }
            
            if addUser {
                model.addUserTask(tid, id: uid) { result in
                    do {
                        let uT = try result.get()
                        //
                    } catch {
                        Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.taskNameField.placeholder = "Task Name"
            self.taskDeadline.date = Date()
            self.taskDescriptionField.text = "Description"
            self.loadTaskTable()
            self.selectedUsersReset = false
            self.setUserMenu()
            
            self.selectedTask.removeAll()
            self.selectedUsers.removeAll()
            self.usersForTask.removeAll()
            
            self.assignedUsersCollection.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        del?.reloadTasksAfterManagerClose()
    }
    
    @IBAction func closeView() {
        del?.reloadTasksAfterManagerClose()
        self.dismiss(animated: true)
    }
}

protocol TaskManagerDelegate {
    func reloadTasksAfterManagerClose()
}

//
//  TaskManagerViewController.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 9/5/23.
//

import PostgresClientKit
import UIKit

class TaskManagerViewController: UIViewController {
    let model = DatabaseManager.shared.connectToDatabase()
    var taskInformation = [Model.Task]()
    var selectedTask = [Model.Task]()
    
    var userInformation = [Model.User]()
    var selectedUsers = [Model.User]()
    
    var usersForTask = [Model.UserTask]()
    
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var taskMenu: UIButton!
    @IBOutlet var taskNameField: UITextField!
    @IBOutlet var taskDescriptionField: UITextView!
    @IBOutlet var userMenu: UIButton!
    @IBOutlet var assignedUsersLabel: UILabel!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var taskDeadline: UIDatePicker!
    
    var del: TaskManagerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        errorLabel.text = ""
        assignedUsersLabel.text = ""
        taskDescriptionField.text = ""
        
        setTaskMenu()
        setUserMenu()
    }
    
    func setTaskMenu() {
        let optionClosure = {(action: UIAction) in self.displayTaskInfo()}
        
        model.getAllTasks() { result in
            do {
                self.taskInformation = try result.get()
                
                var children: [UIMenuElement] = []
                
                let a = UIAction(title: "Current Tasks", state: .on, handler: optionClosure)
                children.append(a)
                
                for task in self.taskInformation {
                    let action = UIAction(title: task.title, handler: optionClosure)
                    children.append(action)
                }
                self.taskMenu.menu = UIMenu(children: children)
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
        
        taskMenu.showsMenuAsPrimaryAction = true
        taskMenu.changesSelectionAsPrimaryAction = true
    }
    
    func displayTaskInfo() {
        selectedTask.removeAll()
        selectedUsers.removeAll()
        usersForTask.removeAll()
        
        let tid = taskInformation.filter {$0.title == taskMenu.menu?.selectedElements.first?.title}.first?.tid
        
        if tid != nil {
            model.taskInformation(tid!) { result in
                do {
                    self.selectedTask = try result.get()
                    
                    self.taskNameField.text = self.selectedTask.first?.title
                    self.taskDeadline.date = (self.selectedTask.first?.deadline.date(in: TimeZone.current))!
                    self.taskDescriptionField.text = self.selectedTask.first?.description
                    
                } catch {
                    Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                }
            }
            
            model.getAllUsersForTID(tid!) { result in
                do {
                    self.usersForTask = try result.get()
                    
                    for userTask in self.usersForTask {
                        let uid = userTask.id
                        self.model.userByID(uid) { result in
                            do {
                                let user = try result.get()
                                self.selectedUsers.append(contentsOf: user)
                                self.assignedUsersLabel.text = self.assignedUsersLabel.text! + user.first!.name + ","
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
    }
    
    func setUserMenu() {
        let optionClosure = {(action: UIAction) in self.getUserInfo()}
        
        model.getAllUsers() { result in
            do {
                self.userInformation = try result.get()
                
                var children: [UIMenuElement] = []
                
                let a = UIAction(title: "Current Users", state: .on, handler: optionClosure)
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
        
        if name != "" {
            model.userByName(name) { result in
                do {
                    let user = try result.get()
                    Postgres.logger.fine(user.first?.name ?? "Something went wrong")
                    if self.selectedUsers.contains(where: { $0.name == user.first?.name }) {
                        self.selectedUsers.removeAll {$0.name == user.first?.name}
                        let assignedUsers = self.assignedUsersLabel.text
                        self.assignedUsersLabel.text = assignedUsers?.replacingOccurrences(of: user.first!.name + ",", with: "")
                        
                    } else {
                        self.selectedUsers.append(contentsOf: user)
                        self.assignedUsersLabel.text = self.assignedUsersLabel.text! + user.first!.name + ","
                    }
                    
                    self.setUserMenu()
                } catch {
                    Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                }
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
                    self.errorLabel.text = "Task Created Successfully, Adding Users Now"
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
        
        errorLabel.text = "Users Added Successfully"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.errorLabel.text = ""
            self.taskNameField.text = ""
            self.taskDeadline.date = Date()
            self.taskDescriptionField.text = ""
            self.assignedUsersLabel.text = ""
            self.setTaskMenu()
            self.setUserMenu()
            
            self.selectedTask.removeAll()
            self.selectedUsers.removeAll()
            self.usersForTask.removeAll()
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
                    self.errorLabel.text = "Task Updated Successfully, Updating Users Now"
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
                        self.errorLabel.text = "Adjusting for Removed Users."
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
                        self.errorLabel.text = "Adding New Users"
                    } catch {
                        Postgres.logger.severe("Error during database communication: \(String(describing: error))")
                    }
                }
            }
        }
        
        errorLabel.text = "New Users Added, Task Updated Successfully"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.errorLabel.text = ""
            self.taskNameField.text = ""
            self.taskDeadline.date = Date()
            self.taskDescriptionField.text = ""
            self.assignedUsersLabel.text = ""
            self.setTaskMenu()
            self.setUserMenu()
            
            self.selectedTask.removeAll()
            self.selectedUsers.removeAll()
            self.usersForTask.removeAll()
        }
    }
    
    @IBAction func deleteTask() {
        let tid = selectedTask.first!.tid
        
        model.deleteTask(tid) { result in
            do {
                let task = try result.get()
                if task.first!.tid == tid {
                    self.errorLabel.text = "Task Removed Successfully"
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.errorLabel.text = ""
                        self.taskNameField.text = ""
                        self.taskDeadline.date = Date()
                        self.taskDescriptionField.text = ""
                        self.assignedUsersLabel.text = ""
                        self.setTaskMenu()
                        self.setUserMenu()
                        
                        self.selectedTask.removeAll()
                        self.selectedUsers.removeAll()
                        self.usersForTask.removeAll()
                    }
                }
            } catch {
                Postgres.logger.severe("Error during database communication: \(String(describing: error))")
            }
        }
    }
    
    func sendNotificationToUsers() {
//        for user in selectedUsers {
//            let token = user.devices.first
//            guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else {
//                return
//            }
//            
//            let json: [String: Any] = [
//                "to": token,
//                "notification": [
//                    
//                    "title": "Test",
//                    "body": "Testing if I can send notifications"
//                ],
//                "data": [
//                    //
//                ]
//                
//            ]
//            
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue(<#T##value: String?##String?#>, forHTTPHeaderField: <#T##String#>)
//        }
//        
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

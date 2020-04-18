//
//  ViewController.swift
//  ToDoListApp
//
//  Created by Михаил Малышев on 12/04/2020.
//  Copyright © 2020 Mikhail Malyshev. All rights reserved.
//

import UIKit
import RealmSwift

class TaskListTableViewController: UITableViewController {
    
     var tasksLists: Results<TaskList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksLists = realm.objects(TaskList.self)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let taskList = tasksLists[indexPath.row]
        cell.configure(with: taskList)
        
        return cell
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        tasksLists = sender.selectedSegmentIndex == 0
            ? tasksLists.sorted(byKeyPath: "name")
            : tasksLists.sorted(byKeyPath: "date")
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentList = tasksLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") { (_, _, _) in
            StorageManager.shared.delete(taskList: currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "edit") { (_, _, isDone) in
            self.showAlert(with: currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "done") { (_, _, isDone) in
            StorageManager.shared.done(taskList: currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .green
        doneAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let taskList = tasksLists[indexPath.row]
        let taskVC = segue.destination as! TaskTableViewController
        taskVC.currentList = taskList
    }
    
    
}

extension TaskListTableViewController {
    
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        
        var title = "New List"
        if taskList != nil { title = "Update List" }
        
        let alert = AlertController(title: title, message: "What do you what to do?", preferredStyle: .alert)
        
        alert.actionWithTaskList(for: taskList) { newValue in
            
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList: taskList, newList: newValue)
                completion()
            } else {
                let taskList = TaskList()
                  taskList.name = newValue
                  
                  StorageManager.shared.save(taskList: taskList)
                  let rowIndex = IndexPath(row: self.tasksLists.count - 1, section: 0)
                  self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        
        present(alert, animated: true)
    }
}

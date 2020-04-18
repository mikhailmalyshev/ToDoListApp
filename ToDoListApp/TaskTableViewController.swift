//
//  TaskTableViewController.swift
//  ToDoListApp
//
//  Created by Михаил Малышев on 14/04/2020.
//  Copyright © 2020 Mikhail Malyshev. All rights reserved.
//

import UIKit
import RealmSwift

class TaskTableViewController: UITableViewController {
    
    var currentList: TaskList!
    
    var currentTasks: Results<Task>!
    var completedTasks: Results<Task>!
    
    private var isEditingMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentList.name
        
        currentTasks = currentList.tasks.filter("isComplete == false")
        completedTasks = currentList.tasks.filter("isComplete == true")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Current Tasks" : "Completed Tasks"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currenTask = indexPath.section == 0
            ? currentTasks[indexPath.row]
            : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") { (_, _, _) in
            StorageManager.shared.delete(task: currenTask)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "edit") { (_, _, isDone) in
            self.showAlert(with: currenTask) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "done") { (_, _, isDone) in
            
            StorageManager.shared.done(task: currenTask)
            
            let indexPathForCurrentTask = IndexPath(row: self.currentTasks.count - 1, section: 0)
            let indexPathForCompletedTask = IndexPath(row: self.completedTasks.count - 1, section: 1)
            let sourceIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            let destinationIndexRow = indexPath.section == 0
                ? indexPathForCompletedTask
                : indexPathForCurrentTask
            
            tableView.moveRow(at: sourceIndexPath, to: destinationIndexRow)
            
            isDone(true)
        }
        
        editAction.backgroundColor = .gray
        doneAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    @IBAction func addTaskButton(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func editTaskButton(_ sender: Any) {
        isEditingMode.toggle()
        tableView.setEditing(isEditingMode, animated: true)
    }
    
}

extension TaskTableViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        
        var title = "New Task"
        if task != nil { title = "Update Task"}
        
        let alert = AlertController(title: title, message: "What do u want to do?", preferredStyle: .alert)
        
        alert.actionWithTask(for: task) { (newValue, note) in
            
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task: task, name: newValue, note: note)
                completion()
            } else {
                let task = Task()
                task.name = newValue
                task.note = note
                
                StorageManager.shared.save(task: task, taskList: self.currentList)
                let rowIndex = IndexPath(row: self.currentTasks.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        
        present(alert, animated: true)
    }
}

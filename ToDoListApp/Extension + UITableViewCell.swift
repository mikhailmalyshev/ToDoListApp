//
//  Extension + UITableViewCell.swift
//  ToDoListApp
//
//  Created by Михаил Малышев on 18/04/2020.
//  Copyright © 2020 Mikhail Malyshev. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        let currentTasks = taskList.tasks.filter("isComplete = false")
        let completedTasks = taskList.tasks.filter("isComplete = true")
        
        textLabel?.text = taskList.name
        
        if !currentTasks.isEmpty {
            detailTextLabel?.text = "\(currentTasks.count)"
            accessoryType = .none
        } else if !completedTasks.isEmpty {
            detailTextLabel?.text = nil
            accessoryType = .checkmark
        } else {
            detailTextLabel?.text = "0"
            accessoryType = .none
        }
        
    }
}

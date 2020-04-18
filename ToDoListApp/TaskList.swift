//
//  TaskList.swift
//  ToDoListApp
//
//  Created by Михаил Малышев on 13/04/2020.
//  Copyright © 2020 Mikhail Malyshev. All rights reserved.
//

import RealmSwift

class Task: Object {
    @objc dynamic var name = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
    @objc dynamic var isComplete = false
}

class TaskList: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    let tasks = List<Task>()
}

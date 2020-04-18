//
//  StorageManager.swift
//  ToDoListApp
//
//  Created by Михаил Малышев on 14/04/2020.
//  Copyright © 2020 Mikhail Malyshev. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    func save(taskList: TaskList) {
        write {
            realm.add(taskList)
        }
    }
    
    func delete(taskList: TaskList) {
        write {
            let tasks = taskList.tasks
            realm.delete(tasks)
            realm.delete(taskList)
        }
    }
    
    func edit(taskList: TaskList, newList: String) {
        write {
            taskList.name = newList
        }
    }
    
    func done(taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    func save(task: Task, taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }
    
    func delete(task: Task) {
        write {
            realm.delete(task)
        }
    }
    
    func edit(task: Task, name: String, note: String) {
        write {
            task.name = name
            task.note = note
        }
    }
    
    func done(task: Task) {
        write {
            task.isComplete.toggle()
        }
    }
    
    private func write(_ completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch let error {
            print(error)
        }
    }
}

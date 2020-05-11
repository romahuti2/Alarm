//
//  TaskScheduler.swift
//  Alarm
//
//  Created by Hipteam on 11.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import UIKit

struct Task {
    var name: String
    var target: Any
    var selector: Selector
    var time: TimeInterval
}

fileprivate struct ScheduledTask {
    var task: Task
    var timer: Timer?
}

class TaskScheduler {
    
    // MARK: - Properties
    
    private var tasks: [ScheduledTask] = []
    
    // MARK: - Public methods
    
    func scheduleTask(_ task: Task) {
        let timer = Timer.scheduledTimer(timeInterval: task.time, target: task.target, selector: task.selector, userInfo: nil, repeats: false)
        let scheduledTask = ScheduledTask(task: task, timer: timer)
        
        RunLoop.main.add(timer, forMode: .common)
        self.tasks.append(scheduledTask)
    }
    
    func cancelTasks() {
        self.tasks.forEach { (task) in
            task.timer?.invalidate()
        }
        self.tasks = []
    }
    
}

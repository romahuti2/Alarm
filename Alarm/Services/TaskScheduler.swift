//
//  TaskScheduler.swift
//  Alarm
//
//  Created by Hipteam on 11.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import UIKit

enum AlarmState {
    case none
    case scheduled
    case started
    case stopped
}

protocol AlarmDelegate: class {
    func alarmStarted()
    func alarmStopped()
}

struct Task {
    var name: String
    var target: Any
    var selector: Selector
    var time: TimeInterval
}

class TaskScheduler {
    
    fileprivate struct ScheduledTask {
        var task: Task
        var timer: Timer?
    }
    
    private var tasks: [ScheduledTask] = []
    
    func scheduleTask(_ task: Task) {
        let timer = Timer.scheduledTimer(timeInterval: task.time, target: task.target, selector: task.selector, userInfo: nil, repeats: false)
        let scheduledTask = ScheduledTask(task: task, timer: timer)
        
        var backgroundTask = UIApplication.shared.beginBackgroundTask {
            
            print("somthing in background?//")
        }
        
        if backgroundTask != .invalid {
            if UIApplication.shared.applicationState == .active {
                UIApplication.shared.endBackgroundTask(backgroundTask)
                backgroundTask = .invalid
            }
        }
        
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

class AlarmScheduler {
    
    var state: Observable<AlarmState> = Observable(.none)
    var notificationsScheduler: NotificationScheduler
    
    init(notificationsScheduler: NotificationScheduler) {
        self.notificationsScheduler = notificationsScheduler
    }
    
    private var timer: Timer?
    
    func addAlarm(in interval: TimeInterval) {
        let timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(startAlarming), userInfo: nil, repeats: false)
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func removeAlarm() {
        timer?.invalidate()
        notificationsScheduler.cancelPendingNotifications()
        self.state.value = .stopped
    }
    
    func stop() {
        self.state.value = .stopped
    }
    
    @objc private func startAlarming() {
        timer?.invalidate()
        self.state.value = .started
    }
    
}

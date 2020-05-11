//
//  NotificationScheduler.swift
//  Alarm
//
//  Created by Hipteam on 10.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import UserNotifications

class NotificationScheduler {
    
    var center: UNUserNotificationCenter
    
    private var date: Date?
    
    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }
    
    func addNotification(date: Date) {
        self.date = date
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermission()
            case .authorized, .provisional:
                self.scheduleNotification()
            default:
                break
            }
        }
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
            if granted == true && error == nil {
                self.scheduleNotification()
            } else {
                //oops
            }
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = "Wake me up inside, Wake me up inside"
        content.categoryIdentifier = "alarm"
        content.sound = .none
        guard let date = date else { return }
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func cancelPendingNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}

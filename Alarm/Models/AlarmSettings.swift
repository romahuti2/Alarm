//
//  AlarmSettings.swift
//  Alarm
//
//  Created by Hipteam on 11.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation

struct AlarmSettings {
    var sleepTime: SleepTime
    var alarmTime: Date
    var alarmSound: URL
    var playSound: URL
    
    mutating func updateSleepTime(_ sleepTime: SleepTime) {
        self.sleepTime = sleepTime
    }
    
    mutating func updateAlertTime(_ alarmTime: Date) {
        self.alarmTime = alarmTime
    }
    
    static var `default`: AlarmSettings {
        let alarmUrl = Bundle.main.url(forResource: "alarm", withExtension: "m4a")!
        let natureUrl = Bundle.main.url(forResource: "nature", withExtension: "m4a")!
        return AlarmSettings(sleepTime: .minutes(1), alarmTime: Date().addingTimeInterval(50), alarmSound: alarmUrl, playSound: natureUrl)
    }
}

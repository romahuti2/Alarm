//
//  TimerFormatter.swift
//  Alarm
//
//  Created by Hipteam on 11.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation

class TimeFormatter: DateFormatter {
    static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }
}

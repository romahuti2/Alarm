//
//  SleepTime.swift
//  Alarm
//
//  Created by Hipteam on 11.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation

enum SleepTime {
    case off
    case minutes(Int)
    
    static func options() -> [SleepTime] {
        return [.off, .minutes(1), .minutes(2), minutes(5), minutes(10)]
    }
    
    static func uiOptions() -> [String] {
        return SleepTime.options().map { $0.uiRepresentation }
    }
    
    var uiRepresentation: String {
        switch self {
        case .off:
            return "Off"
        case .minutes(let minutes):
            let noun = minutes == 1 ? "minute" : "minutes"
            return "\(minutes) \(noun)"
        }
    }
    
    func minutes() -> Int {
        switch self {
        case .off:
            return 0
        case .minutes(let minutes):
            return minutes
        }
    }
}

func ==(lhs: SleepTime, rhs: SleepTime) -> Bool {
    switch (lhs, rhs) {
    case (.off, .off):
        return true
    case (.minutes(let lm), .minutes(let rm)):
        return lm == rm
    default:
        return false
    }
}

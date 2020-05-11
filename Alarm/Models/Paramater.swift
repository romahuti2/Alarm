//
//  Paramater.swift
//  Alarm
//
//  Created by Hipteam on 11.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation

enum ParameterType: Int {
    case alarmTime = 0
    case sleepTime
}

struct Parameter {
    var type: ParameterType
    var key: String
    var value: String
}

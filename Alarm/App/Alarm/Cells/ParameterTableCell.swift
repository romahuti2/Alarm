//
//  ParameterTableCell.swift
//  Alarm
//
//  Created by Hipteam on 08.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import UIKit

enum ParameterType: Int {
    case alarmTime = 0
    case sleepTime
}

struct Parameter {
    var type: ParameterType
    var key: String
    var value: String
}

class ParameterTableCell: UITableViewCell {
    
    @IBOutlet private weak var keyLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    func configure(parameter: Parameter) {
        self.keyLabel.text = parameter.key
        self.valueLabel.text = parameter.value
    }
    
}

extension UIView {
    static var className: String {
        return String(describing: self)
    }
}

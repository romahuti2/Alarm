//
//  BindableUIDatePicker.swift
//  Alarm
//
//  Created by Hipteam on 09.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import UIKit

class BindableUIDatePicker : UIDatePicker {
    
    private var dateChanged: (Date) -> () = { _ in }
    
    func bind(callback :@escaping (Date) -> ()) {
        self.dateChanged = callback
        self.addTarget(self, action: #selector(pickerDateChanged), for: .valueChanged)
    }
    
    @objc func pickerDateChanged(_ picker: UIDatePicker) {
        self.dateChanged(picker.date)
    }
    
}

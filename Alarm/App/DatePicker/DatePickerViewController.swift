//
//  PickerController.swift
//  Alarm
//
//  Created by Hipteam on 09.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import UIKit

final class DatePickerViewController: UIViewController {

    // MARK: - UI
    
    var maximumDate: Date?
    var selectedDate: Date?
    
    var viewModel: DatePickerViewModelType!
    
    lazy var textField: UITextField = {
        let field: UITextField = UITextField()
        
        return field
    }()
    
    lazy var toolbar: UIToolbar = {
        let doneButtonTextColor: UIColor = UIColor.black
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        doneButton.tintColor = .systemBlue
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        cancelButton.tintColor = .systemRed
        
        let toolBar: UIToolbar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.barTintColor = .opaqueSeparator
        toolBar.sizeToFit()
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }()
    
    lazy var datePickerView: UIDatePicker = {
        let picker = BindableUIDatePicker()
        picker.backgroundColor = .systemBackground
        picker.datePickerMode = .time
        picker.maximumDate = self.maximumDate
        if let date = selectedDate {
            picker.setDate(date, animated: false)
        }
        picker.timeZone = TimeZone.current
        picker.locale = Locale.current
        picker.bind { [unowned self] (date) in
            self.viewModel.selectedDate.value = date
        }
        return picker
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        self.view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelClick))
        self.view.addGestureRecognizer(tap)
        
        addDatePicker()
        
        self.setPickerView(isHidden: false)
        viewModel.selectedDate.bindAndFire { (observer, value) in
            self.datePickerView.date = value
        }
        viewModel.isPickerHidden.bind { [unowned self] (obs, value) in
            self.setPickerView(isHidden: value)
        }
    }
    
    var currentDate: Date {
        return datePickerView.date
    }
    
    func addDatePicker() {
        textField.inputView = datePickerView
        textField.inputAccessoryView = toolbar
        view.addSubview(textField)
    }
    
    func setPickerView(isHidden: Bool) {
        if isHidden {
            textField.resignFirstResponder()
        } else {
            textField.becomeFirstResponder()
        }
    }
    
    // MARK: - IBActions
    
    @objc private func doneClick() {
        viewModel.doneBarButtonTaped()
    }
    
    @objc private func cancelClick() {
        viewModel.dismiss()
    }

}

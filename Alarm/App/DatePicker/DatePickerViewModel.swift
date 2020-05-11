//
//  PickerViewModel.swift
//  Alarm
//
//  Created by Hipteam on 09.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation

protocol DatePickerDelegate: class {
    func onDateSelected(_ pickerModel: DatePickerViewModel, _ date: Date)
    func onDimiss()
}

protocol DatePickerViewModelType {
    var selectedDate: Observable<Date> { get }
    var isPickerHidden: Observable<Bool> { get }
    var delegate: DatePickerDelegate? { get set }
    
    func doneBarButtonTaped()
    func dismiss()
}
    
class DatePickerViewModel: DatePickerViewModelType {
    
    // MARK: - Properties
    
    var selectedDate: Observable<Date>
    var isPickerHidden: Observable<Bool> = Observable.init(false)
    var animation: Observable<Bool> = Observable.init(true)
    weak var delegate: DatePickerDelegate?
    
    // MARK: - Initialize
    
    init(selectedDate: Date?, delegate: DatePickerDelegate? = nil) {
        self.selectedDate = Observable(selectedDate ?? Date())
        self.delegate = delegate
    }
    
    // MARK: - Public methods
    
    func doneBarButtonTaped() {
        delegate?.onDateSelected(self, selectedDate.value)
    }
    
    func dismiss() {
        isPickerHidden.value = true
        delegate?.onDimiss()
    }
}

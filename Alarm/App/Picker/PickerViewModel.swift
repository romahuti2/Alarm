//
//  PickerViewModel.swift
//  Alarm
//
//  Created by Hipteam on 09.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation

protocol PickerViewDelegate: class {
    func onDateSelected(_ pickerModel: PickerViewModel, _ date: Date)
    func onDimiss()
}

protocol PickerViewModelType {
    var selectedDate: Observable<Date> { get }
    var isPickerHidden: Observable<Bool> { get }
    var delegate: PickerViewDelegate? { get set }
    
    func doneBarButtonTaped()
    func dismiss()
}
    
class PickerViewModel: PickerViewModelType {
    
    init(selectedDate: Date?, delegate: PickerViewDelegate? = nil) {
        self.selectedDate = Observable(selectedDate ?? Date())
        self.delegate = delegate
    }
    
    var selectedDate: Observable<Date>
    var isPickerHidden: Observable<Bool> = Observable.init(false)
    var animation: Observable<Bool> = Observable.init(true)
    weak var delegate: PickerViewDelegate?
    
    func doneBarButtonTaped() {
        delegate?.onDateSelected(self, selectedDate.value)
    }
    
    func dismiss() {
        isPickerHidden.value = true
        delegate?.onDimiss()
    }
}

//
//  PickerCoordinator.swift
//  Alarm
//
//  Created by Hipteam on 09.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation

class DatePickerCoordinator: BaseCoordinator {
    
    private var selectedDate: Date
    private var delegate: DatePickerDelegate?
    
    init(selectedDate: Date? = Date(), delegate: DatePickerDelegate? = nil) {
        self.selectedDate = selectedDate ?? Date()
        self.delegate = delegate
        super.init()
    }
    
    override func start() {
        let viewController = DatePickerViewController()
        
        let viewModel = DatePickerViewModel(selectedDate: selectedDate, delegate: self)
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .overCurrentContext
        
        navigationController.topViewController?.present(viewController, animated: true, completion: nil)
    }

}

extension DatePickerCoordinator: DatePickerDelegate {
    func onDateSelected(_ pickerModel: DatePickerViewModel, _ date: Date) {
        delegate?.onDateSelected(pickerModel, date)
        navigationController.topViewController?.dismiss(animated: true, completion: nil)
    }
    
    func onDimiss() {
        delegate?.onDimiss()
        navigationController.topViewController?.dismiss(animated: true, completion: nil)
    }
    
}

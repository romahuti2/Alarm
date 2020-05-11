//
//  PickerCoordinator.swift
//  Alarm
//
//  Created by Hipteam on 09.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation

protocol PickerCoordinatorDelegate: class {
    func dimissPicker()
}

class PickerCoordinator: BaseCoordinator {
    
    private var selectedDate: Date
    private var delegate: PickerViewDelegate?
    
    init(selectedDate: Date? = Date(), delegate: PickerViewDelegate? = nil) {
        self.selectedDate = selectedDate ?? Date()
        self.delegate = delegate
        super.init()
    }
    
    override func start() {
        let viewController = DatePickerViewController()
        
        let viewModel = PickerViewModel(selectedDate: selectedDate, delegate: self)
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .overCurrentContext
        
        navigationController.topViewController?.present(viewController, animated: true, completion: nil)
    }

}

extension PickerCoordinator: PickerViewDelegate {
    func onDateSelected(_ pickerModel: PickerViewModel, _ date: Date) {
        delegate?.onDateSelected(pickerModel, date)
        navigationController.topViewController?.dismiss(animated: true, completion: nil)
    }
    
    func onDimiss() {
        delegate?.onDimiss()
        navigationController.topViewController?.dismiss(animated: true, completion: nil)
    }
    
}

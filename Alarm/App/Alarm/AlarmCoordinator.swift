//
//  AlarmCoordinator.swift
//  Alarm
//
//  Created by Hipteam on 09.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import UIKit

protocol AlarmCoordinatorDelegate {
    
}

class AlarmCoordinator: BaseCoordinator {
    
    override func start() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier:
                "AlarmViewController") as? AlarmViewController else {
                fatalError("No AlarmViewController")
        }

        let audioService = BoosterAudioService(player: AudioPlayer(), recorder: AudioRecorder(recordLibrary: DocumentsRecordLibrary()))
        let scheduler = TaskScheduler()
        let notificationScheduler = NotificationScheduler()
        let viewModel = AlarmViewModel(settings: AlarmSettings.default, audioService: audioService, scheduler: scheduler, notificationSheduler: notificationScheduler)
        audioService.delegate = viewModel
        viewModel.onSelectSleepTime = { model in
            self.showSleepTimePicker(viewModel: model)
        }
        viewModel.onSelectAlarmTime = { model in
            self.showDatePicker(selectedDate: model.alarmSettings.value.alarmTime, delegate: model)
        }
        viewModel.onAlarmStart = { [unowned self] model in
            let alert = UIAlertController(title: "Alarm", message: "Wake up, sweety", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Stop", style: .default, handler: {  (action) in
                viewModel.stopAlarm()
            }))
            self.navigationController.topViewController?.present(alert, animated: true, completion: nil)
        }
        viewModel.errorToShow.bind { (observer, error) in
            let alert = UIAlertController(title: "Error", message: error?.localizedDescription ?? "Unknown error happened", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.navigationController.topViewController?.present(alert, animated: true, completion: nil)
        }
        
        viewController.viewModel = viewModel
        self.navigationController.setViewControllers([viewController], animated: true)
    }
    
    private func showDatePicker(selectedDate: Date?, delegate: PickerViewDelegate?) {
        let datePickerCoordinator = PickerCoordinator(selectedDate: selectedDate, delegate: delegate)
        datePickerCoordinator.parentCoordinator = self
        datePickerCoordinator.navigationController = navigationController
        
        start(coordinator: datePickerCoordinator)
    }
    
    private func showSleepTimePicker(viewModel: AlarmViewModel) {
        let actionSheet = UIAlertController(title: "Select", message: nil, preferredStyle: .actionSheet)
        SleepTime.options().forEach { sleepTime in
            let action = SleepAlertAction(title: sleepTime.uiRepresentation, style: .default, handler: { [unowned viewModel] action in
                guard let action = action as? SleepAlertAction, let time = action.sleepTime else { return }
                viewModel.changeSleepTime(time)
            })
            action.sleepTime = sleepTime
            actionSheet.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        navigationController.topViewController?.present(actionSheet, animated: true, completion: nil)
    }
    
}

class SleepAlertAction: UIAlertAction {
    var sleepTime: SleepTime?
    
}


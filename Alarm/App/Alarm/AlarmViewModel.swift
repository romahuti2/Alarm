//
//  ViewModel.swift
//  Alarm
//
//  Created by Hipteam on 09.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation

struct ParametersViewModel {
    var sleepTime: String
    var alarmTime: String
}

enum AlarmViewModelAudioState: String {
    case idle = "Idle"
    case playing = "Playing"
    case recoding = "Recording"
    case paused = "Pause"
    case alarm = "Alarm"
    
    func canPause() -> Bool {
        return [AlarmViewModelAudioState.playing, .recoding].contains(self)
    }
    
    func canStart() -> Bool {
        return self != .alarm
    }
}

protocol AlarmViewModelType {
    var parameters: Observable<[Parameter]> { get }
    var alarmTime: Observable<String> { get }
    var sleepTime: Observable<String> { get }
    var stateText: Observable<String> { get }
    var playButtonTitle: Observable<String> { get }
    var errorToShow: Observable<Error?> { get }
    var audioService: AudioService { get }
    var scheduler: TaskScheduler { get }
    var notificationScheduler: NotificationScheduler { get }
    
    func selectAlarmTime()
    func selectSleepTime()
    
    func playPause()
    func stopAlarm()
    
    func transform()
}

class AlarmViewModel: AlarmViewModelType {
    
    // MARK: Properties
    
    private(set) var alarmSettings: Observable<AlarmSettings>
    var parameters: Observable<[Parameter]> = Observable([])
    var alarmTime: Observable<String> = Observable("")
    var sleepTime: Observable<String> = Observable("")
    var playButtonTitle: Observable<String> = Observable("")
    var errorToShow: Observable<Error?> = Observable(nil)
    var stateText: Observable<String> = Observable("Idle")
    var onSelectAlarmTime: ((AlarmViewModel) -> ())?
    var onSelectSleepTime: ((AlarmViewModel) -> ())?
    var onAlarmStart: ((AlarmViewModel) -> ())?
    
    var audioState: AlarmViewModelAudioState = .idle {
        didSet {
            self.previousAudioState = oldValue
            self.stateText.value = audioState.rawValue
            self.playButtonTitle.value = audioState.canPause() ? "Pause" : "Play"
        }
    }
    private var previousAudioState: AlarmViewModelAudioState  = .idle
    
    var audioService: AudioService
    var scheduler: TaskScheduler
    var notificationScheduler: NotificationScheduler
    
    // MARK: Initialize
    
    init(settings: AlarmSettings, audioService: AudioService, scheduler: TaskScheduler, notificationSheduler: NotificationScheduler) {
        self.alarmSettings = Observable(settings)
        self.audioService = audioService
        self.scheduler = scheduler
        self.notificationScheduler = notificationSheduler
    }
    
    // MARK: Public methods
    
    func transform() {
        playButtonTitle = Observable(audioState.canPause() ? "Pause" : "Play")
        alarmSettings.bindAndFire { [unowned self] (observer, value) in
            let alarmTime = TimeFormatter.formatter.string(from: value.alarmTime)
            self.parameters.value = [Parameter(type: .alarmTime, key: "Alarm time", value: alarmTime),
                                     Parameter(type: .sleepTime, key: "Sleep time", value: value.sleepTime.uiRepresentation)]
        }
    }
    
    func selectAlarmTime() {
        onSelectAlarmTime?(self)
    }
    
    func selectSleepTime() {
        onSelectSleepTime?(self)
    }
    
    func stopAlarm() {
        audioService.executeCommand(.stop)
        self.audioState = .idle
        scheduler.cancelTasks()
        notificationScheduler.cancelPendingNotifications()
    }
    
    func changeSleepTime(_ sleepTime: SleepTime) {
        alarmSettings.value.updateSleepTime(sleepTime)
    }

    func playPause() {
        switch audioState {
        case .idle:
            startFlow()
            addAlarm()
        case .paused:
            //Tapping on play/pause should start the entire flow or pause playing or recording, but not the alarm
            //this can be understood in 2 ways.
            //1. tap on play after pause - start all again, except alarm
            //2. tap play after pause - will resume play/record, except alarm
            
            //1
            //            startFlow()
            
            //2
            resume()
        case .playing, .recoding:
            pause()
        default: ()
        }
    }
    
    // MARK: Private methods
    
    private func startFlow() {
        let sleepTime = TimeInterval(alarmSettings.value.sleepTime.minutes() * 60)
        let task = Task(name: "recording", target: self, selector: #selector(startRecording), time: sleepTime)
        
        scheduler.scheduleTask(task)
        
        if alarmSettings.value.sleepTime == .off {
            return
        }
        audioService.executeCommand(.play(alarmSettings.value.playSound))
        self.audioState = .playing
    }
    
    private func pause() {
        if audioState.canPause() {
            audioService.executeCommand(.pause)
            self.audioState = .paused
        }
    }
    
    private func addAlarm() {
        let alarmTime = alarmSettings.value.alarmTime.timeIntervalSinceNow
        let alarmTask = Task(name: "alarm", target: self, selector: #selector(startAlarm), time: alarmTime)
        
        scheduler.scheduleTask(alarmTask)
        
        notificationScheduler.cancelPendingNotifications()
        notificationScheduler.addNotification(date: alarmSettings.value.alarmTime)
    }
    
    @objc func startAlarm() {
        audioService.executeCommand(.play(alarmSettings.value.alarmSound))
        onAlarmStart?(self)
        self.audioState = .alarm
    }
    
    @objc private func startRecording() {
        if audioState.canStart() {
            audioService.executeCommand(.record)
            self.audioState = .recoding
        }
    }
    
    private func resume(force: Bool = false) {
        if self.previousAudioState != .alarm || force {
            audioService.executeCommand(.resume)
            self.audioState = self.previousAudioState
        }
    }
    
}

// MARK: DatePickerDelegate

extension AlarmViewModel: DatePickerDelegate {
    
    func onDimiss() { }
    
    func onDateSelected(_ pickerModel: DatePickerViewModel, _ date: Date) {
        alarmSettings.value.updateAlertTime(date)
    }
}

// MARK: AudioServiceDelegate

extension AlarmViewModel: AudioServiceDelegate {
    
    func audioService(_ audioService: AudioService, interruption: AudioInterruptionType) {
        switch interruption {
        case .began:
            pause()
        case .endedWithResume(let canResume):
            if canResume {
                print("try resume")
                resume(force: true)
            } else {
                audioService.executeCommand(.stop)
                audioState = .idle
            }
        }
    }
    
    func audioService(_ audioService: AudioService, error: Error) {
        self.errorToShow.value = error
        audioService.executeCommand(.stop)
        self.audioState = .idle
    }
    
}

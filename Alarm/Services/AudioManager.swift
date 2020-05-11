//
//  AudioManager.swift
//  Alarm
//
//  Created by Hipteam on 08.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioError: LocalizedError {
    case noPermission
    
    var localizedDescription: String {
        switch self {
        case .noPermission:
            return "You are not allowed to record. Please provide recording permission in settings"
        }
    }
}

enum AudioServiceState {
    case idle
    case playing
    case recoding
    case pausedPlaying
    case pausedRecording
}

protocol AudioService {
    var state: AudioServiceState { get }
    var delegate: AudioServiceDelegate? { get set }
    var player: AudioPlayerType { get }
    var recorder: AudioRecorderType { get }
    
    func executeCommand(_ command: AudioCommand)
}

enum AudioInterruptionType {
    case began
    case endedWithResume(Bool)
}

protocol AudioServiceDelegate: class {
    func audioService(_ audioService: AudioService, interruption: AudioInterruptionType)
    func audioService(_ audioService: AudioService, error: Error)
}

enum AudioSessionState {
    case notConfigured
    case error
    case noPermission
    case ready
    case active
}

enum AudioCommand {
    case play(URL)
    case pause
    case record
    case stop
    case resume
}

class BoosterAudioService: NSObject, AudioService {
    
    // MARK: - Properties
    
    var state: AudioServiceState = .idle
    var player: AudioPlayerType
    var recorder: AudioRecorderType
    
    weak var delegate: AudioServiceDelegate?
    let session = AVAudioSession.sharedInstance()
    var sessionState: AudioSessionState = .notConfigured
    
    // MARK: - Initialize
    
    init(player: AudioPlayerType, recorder: AudioRecorderType, delegate: AudioServiceDelegate? = nil) {
        self.player = player
        self.recorder = recorder
        self.delegate = delegate
        super.init()
        
        self.player.errorHandler = { [unowned self] error in
            if let error = error {
                self.delegate?.audioService(self, error: error)
                self.state = .idle
            }
        }
        
        self.recorder.errorHandler = { [unowned self] error in
            if let error = error {
                self.delegate?.audioService(self, error: error)
                self.state = .idle
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public methods
    
    func executeCommand(_ command: AudioCommand) {
        switch command {
        case .play(let url):
            if recorder.isRecording {
                recorder.stop()
            }
            if sessionState != .active {
                activateSession()
            }
            player.setTrack(url)
            player.play()
            self.state = .playing
        case .pause:
            pause()
        case .record:
            record()
        case .stop:
            player.stop()
            recorder.stop()
            deactivateSession()
            self.state = .idle
        case .resume:
            if sessionState != .active {
                activateSession()
            }
            if state == .pausedRecording {
                recorder.record()
                self.state = .recoding
            } else if state == .pausedPlaying {
                player.play()
                self.state = .playing
            }
        }
    }
    
    // MARK: - Private methods
    
    private func hasPermission() -> Bool {
        return session.recordPermission == .granted
    }
    private func activateSession(for category: AVAudioSession.Category = .playAndRecord) {
        do {
            try session.setCategory(category, options: [])
            self.sessionState = .ready
            
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            self.sessionState = .active
        } catch let error as NSError {
            self.sessionState = .error
            self.delegate?.audioService(self, error: error)
            self.state = .idle
            print("could not active session. err:\(error.localizedDescription)")
        }
    }
    
    private func deactivateSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            self.sessionState = .notConfigured
        } catch let error as NSError {
            self.sessionState = .error
            self.delegate?.audioService(self, error: error)
            self.state = .idle
            print("could not deactive session. err:\(error.localizedDescription)")
        }
    }
    
    private func requestPermission() {
        switch session.recordPermission {
        case .denied:
            self.delegate?.audioService(self, error: AudioError.noPermission)
            self.sessionState = .noPermission
            break
        case .granted:
            self.startRecording()
            break
        case .undetermined:
            session.requestRecordPermission { [unowned self] (granted) in
                if granted {
                    self.startRecording()
                } else {
                    self.delegate?.audioService(self, error: AudioError.noPermission)
                    self.sessionState = .noPermission
                }
            }
        @unknown default: ()
        }
    }
    
    private func record() {
        if hasPermission() {
            startRecording()
        } else {
            requestPermission()
        }
    }
    
    private func startRecording() {
        if player.isPlaying {
            player.stop()
        }
        if sessionState != .active {
            activateSession()
        }
        recorder.record()
        self.state = .recoding
    }
    
    private func pause() {
        if player.isPlaying {
            player.pause()
            self.state = .pausedPlaying
        } else if recorder.isRecording {
            recorder.pause()
            self.state = .pausedRecording
        }
    }
    
    @objc func sessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        switch type {
        case .began:
            self.delegate?.audioService(self, interruption: .began)
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                self.delegate?.audioService(self, interruption: .endedWithResume(false))
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            self.delegate?.audioService(self, interruption: .endedWithResume(options.contains(.shouldResume)))
        default: ()
        }
    }
}

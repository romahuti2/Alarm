//
//  AudioPlayer.swift
//  Alarm
//
//  Created by Hipteam on 10.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import AVFoundation

enum RecorderState {
    case prepareToRecord
    case recording
    case pause
    case stop
    case finish
    case failed
    
    func canResume() -> Bool {
        return [RecorderState.pause, .prepareToRecord].contains(self)
    }
}

protocol AudioRecorderType {
    var recordLibrary: RecordLibrary { get }
    var state: Observable<RecorderState> { get }
    var errorHandler: ((Error?) -> ())? { get set }
    
    func prepareToRecord()
    func record()
    func pause()
    func stop()
    
    var isRecording: Bool { get }
}

protocol RecordLibrary {
    var fileManager: FileManager { get }
    
    func generateUrl(for name: String) -> URL?
}

class DocumentsRecordLibrary: RecordLibrary {
    
    var fileManager: FileManager
    
    private let fileExtension = ".m4a"
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    private func documentsDirectory() -> URL? {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func generateUrl(for name: String) -> URL? {
        return documentsDirectory()?.appendingPathComponent(name + fileExtension)
    }
    
}

class AudioRecorder: NSObject, AudioRecorderType {
    
    private(set) var recordLibrary: RecordLibrary
    
    private var avRecorder: AVAudioRecorder?
    var errorHandler: ((Error?) -> ())?
        
    var state: Observable<RecorderState> = Observable(.stop)
    
    var isRecording: Bool {
        return avRecorder?.isRecording ?? false
    }
    
    init(recordLibrary: RecordLibrary) {
        self.recordLibrary = recordLibrary
    }
    
    func record() {
        if state.value.canResume() {
            avRecorder?.record()
            state.value = .recording
        } else {
            prepareToRecord()
            record()
        }
    }
    
    func prepareToRecord() {
        configure()
    }
    
    func pause() {
        guard avRecorder != nil else { return }

        avRecorder?.pause()
        state.value = .pause
    }
    
    func stop() {
        guard avRecorder != nil else { return }

        avRecorder?.stop()
        state.value = .stop
    }
    
    private func configure() {
        do {
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            guard let url = recordLibrary.generateUrl(for: "Record \(Date())") else {
                state.value = .failed
                return
            }
            avRecorder = try AVAudioRecorder(url: url, settings: settings)
            avRecorder?.delegate = self
            avRecorder?.prepareToRecord()
            state.value = .prepareToRecord
        } catch let error {
            state.value = .failed
            errorHandler?(error)
        }
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            state.value = .finish
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            state.value = .failed
            errorHandler?(error)
        }
    }
}

//
//  Player.swift
//  Alarm
//
//  Created by Hipteam on 10.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayerType {
    
    var errorHandler: ((Error?) -> ())? { get set }
    func setTrack(_ url: URL)
    
    func play()
    func pause()
    func stop()
    
    var isPlaying: Bool { get }
}

class AudioPlayer: NSObject, AudioPlayerType {
    
    // MARK: - Properties
    
    private var avPlayer: AVAudioPlayer?
    
    var errorHandler: ((Error?) -> ())?
    var isPlaying: Bool {
        return avPlayer?.isPlaying ?? false
    }
    
    // MARK: - Public methods
    
    func setTrack(_ url: URL) {
        do {
            self.avPlayer = try AVAudioPlayer(contentsOf: url)
            avPlayer?.numberOfLoops = -1
            self.avPlayer?.delegate = self
        } catch {
            self.errorHandler?(error)
        }
    }
    
    func play() {
        guard let player = avPlayer else { return }
        player.prepareToPlay()
        player.play()
    }
    
    func pause() {
        guard let player = avPlayer else { return }
        if player.isPlaying {
            player.pause()
        }
    }
    
    func stop() {
        guard let player = avPlayer else { return }
        
        if player.isPlaying {
            player.stop()
        }
    }
    
}

// MARK: - AVAudioPlayerDelegate

extension AudioPlayer: AVAudioPlayerDelegate {
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.errorHandler?(error)
    }
}

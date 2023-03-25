//
//  PlaySound.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-20.
//

import Foundation
import AVKit
import Combine


class PlayerWord: ObservableObject {
    // Player variables
    var player = AVPlayer()
    var volume: Float = 0
    
    private var playerStatusObserver: AnyCancellable?
    
    init() {
        playerStatusObserver = player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { status in
                switch status {
                case .paused, .waitingToPlayAtSpecifiedRate:
                    NotificationCenter.default.post(name: .playerStopped, object: nil)
                default:
                    break
                }
            }
    }
    
    func play(url: String, state: Bool) {
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(AVAudioSession.Category.playback)
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                
                player = AVPlayer(url: URL(string: url)!)
                
                if state {
                    player.play()
                } else {
                    player.pause()
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func togglePlayingState(url: String) {
        let currentState = player.timeControlStatus != .playing
        play(url: url, state: currentState)
    }
}


extension AVPlayer {
    func publisher<T>(for keyPath: KeyPath<AVPlayer, T>) -> AnyPublisher<T, Never> {
        return KeyValueObservingPublisher(object: self, keyPath: keyPath, options: [])
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension NotificationCenter {
    static let playerStopped = Notification.Name("playerStopped")
}

extension NSNotification.Name {
    static let playerStopped = NSNotification.Name("playerStopped")
}



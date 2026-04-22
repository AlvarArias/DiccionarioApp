//
//  PlaySound.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-20.
//

import Foundation
import AVKit
import Combine

@MainActor
class PlayerWord: ObservableObject {
    var player = AVPlayer()
    var volume: Float = 0

    private var playerStatusObserver: AnyCancellable?

    init() {
        playerStatusObserver = player.publisher(for: \.timeControlStatus, options: [])
            .receive(on: RunLoop.main)
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
    }

    func togglePlayingState(url: String) {
        let currentState = player.timeControlStatus != .playing
        play(url: url, state: currentState)
    }
}

extension NotificationCenter {
    static let playerStopped = Notification.Name("playerStopped")
}

extension NSNotification.Name {
    static let playerStopped = NSNotification.Name("playerStopped")
}

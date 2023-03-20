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
    @Published var isPlaying: Bool = false
    var volume: Float = 0
    
    @Published var playerStopped: Bool = false

    
    private var playerStatusObserver: AnyCancellable?
    
    init() {
        playerStatusObserver = player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { status in
                switch status {
                case .paused:
                    self.isPlaying = false
                    print("Player stopped")
                    self.playerStopped = true
                case .playing:
                    self.isPlaying = true
                    self.playerStopped = false
                default:
                    break
                }
            }

    }
    
    func play(url: String, state: Bool) {
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(AVAudioSession.Category.playback)
            print("AVAudioSession Category Playback OK")
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
                
                player = AVPlayer(url: URL(string: url)!)
                
                if state {
                    print("player.play()")
                    player.play()
                    
                } else {
                    print("player.pause()")
                    player.pause()
                    
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
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




/*
class PlayerWord {
    
    // Player variables
    var player = AVPlayer()
    var isPlaying : Bool = false
    var volum : Float = 0
   
    
    func Play(url: String, state: Bool) {
        
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(AVAudioSession.Category.playback)
            print("AVAudioSession Category Playback OK")
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
                
                player = AVPlayer(url: URL(string: url)!)
  
                    if state {
                        print("player.play()")
                        player.play()
                        
                    } else {
                        print("player.pause()")
                        player.pause()
                        
                    }

                
                
       
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            
        }
        
       
    }
  
}

extension AVPlayer {
var isPlaying: Bool {
if (self.rate != 0 && self.error == nil) {
return true
        } else {
return false
        }
    }
}

*/

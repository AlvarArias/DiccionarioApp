//
//  PlaySound.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-20.
//

import Foundation
import AVKit

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

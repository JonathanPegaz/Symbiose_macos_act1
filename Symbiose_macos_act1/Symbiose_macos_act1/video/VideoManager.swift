//
//  VideoManager.swift
//  Symbiose
//
//  Created by Jonathan Pegaz on 29/12/2022.
//

import Foundation
import AVKit
import Combine

class VideoManager: ObservableObject {
    @Published var player = AVPlayer(url:Bundle.main.url(forResource: "video", withExtension: "mp4")!)
    @Published var step = 0
    @Published private var boundaryTimeObserver:Any?
    @Published var currentTime: Double = 0.0
    @Published var timelimit: Double = 0.0
    
    private var timeObservation: Any?
    
    let loopTimeTest = CMTime(seconds: 1, preferredTimescale: 60000)
    let anchorTimeTest = CMTime(seconds: 0, preferredTimescale: 60000)
    
    var loopDelay = 0.0
    var anchorDelay = 0.0
    
    init() {
      // Periodically observe the player's current time, whilst playing
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
        guard let self = self else { return }
        // Publish the new player time
        self.currentTime = time.seconds
      }
        
    }
    
    func changeStep(step: Int) {
                
        if(self.boundaryTimeObserver != nil) {
            self.player.removeTimeObserver(self.boundaryTimeObserver)
        }
        
        switch step {
            
            case 1:
                var videoStartTime: CMTime = CMTimeMake(value: 0, timescale: 1)
                player.seek(to: videoStartTime)
                self.step = 1
                self.timelimit = 3
                
                self.player.play()
                
                

            case 2:
                print("step2")
                
                self.step = 2
                self.timelimit = 6
                self.player.play()
                
            
            case 3:
                print("step3")
//                var videoStartTime: CMTime = CMTimeMake(value: 12, timescale: 1)
//                player.seek(to: videoStartTime)
                self.step = 3
                self.timelimit = 12
                self.player.play()
        
            case 4:
                print("step4")
//                var videoStartTime: CMTime = CMTimeMake(value: 18, timescale: 1)
//                player.seek(to: videoStartTime)
                self.step = 4
                self.timelimit = 18
                self.player.play()
            
            case 5:
                print("step6")
//                var videoStartTime: CMTime = CMTimeMake(value: 24, timescale: 1)
//                player.seek(to: videoStartTime)
                self.step = 5
                self.timelimit = 24
                self.player.play()
            
            case 6:
                print("step6")
//                var videoStartTime: CMTime = CMTimeMake(value: 30, timescale: 1)
//                player.seek(to: videoStartTime)
                self.step = 6
                self.timelimit = 30
                self.player.play()
            
            case 7:
                self.step = 7
//                var videoStartTime: CMTime = CMTimeMake(value: 36, timescale: 1)
//                player.seek(to: videoStartTime)
                self.timelimit = 36
                self.player.play()
            default:
                print("Cette étape n'existe pas")
        }
        
        let loopTime = CMTime(seconds: self.loopDelay, preferredTimescale: 60000)
        let anchorTime = CMTime(seconds: self.anchorDelay, preferredTimescale: 60000)
        
        self.boundaryTimeObserver = self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: loopTime)], queue: DispatchQueue.main) {
            self.player.seek(to: anchorTime)
        }
        
    }
}

//
//  ContentView.swift
//  Symbiose_macos_act1
//
//  Created by Jonathan Pegaz on 09/01/2023.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject var videoManager:VideoManager = VideoManager()
    @StateObject var bleController:BLEController = BLEController()
    @StateObject var freqMactcher: FrequencyMatcher = FrequencyMatcher()
    
    @State var act1ok:Bool = false
    
    var body: some View {
        VStack {
            PlayerView(player: videoManager.player)
        }
        .padding()
        .onAppear(){
            bleController.load()
        }
        .onChange(of: bleController.bleStatus, perform: { newValue in
            bleController.addServices()
        })
        .onChange(of: bleController.messageLabel) { newValue in
            if (newValue == "start") {
                videoManager.changeStep(step: 1)
                freqMactcher.startListening()
            }
            if (newValue == "reset") {
                videoManager.player.pause()
                var videoStartTime: CMTime = CMTimeMake(value: 0, timescale: 1)
                videoManager.player.seek(to: videoStartTime)
                videoManager.player.rate = 1.0
                videoManager.changeStep(step: 1)
                freqMactcher.startListening()
            }
        }
        .onChange(of: freqMactcher.freqResult, perform: { newValue in
            if(videoManager.step < 7){
                if (videoManager.currentTime < videoManager.timelimit) {
                    videoManager.player.rate *= 1.2
                } else {
                    videoManager.changeStep(step: videoManager.step + 1)
                }
            }
        })
        .onChange(of: videoManager.currentTime, perform: { newValue in
            if (newValue > videoManager.timelimit && videoManager.step < 7) {
                videoManager.player.rate = 1.0
                videoManager.player.pause()
                print("pause")
            }
        })
        .onChange(of: videoManager.step) { newValue in
            if (newValue == 7) {
                bleController.sendEndValue()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


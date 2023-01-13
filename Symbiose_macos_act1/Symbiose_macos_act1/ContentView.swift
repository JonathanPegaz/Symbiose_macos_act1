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
    
    @State var isReady: Bool = false
    
    @State var act1ok:Bool = false
    
    var body: some View {
        VStack {
            PlayerView(player: videoManager.player)
//            Button("skip"){
//                videoManager.changeStep(step: 7)
//            }
//            Button("reset"){
//                videoManager.changeStep(step: 1)
//                bleController.messageLabel = ""
//            }
        }
        .padding()
        .onAppear(){
            bleController.load()
        }
        .onChange(of: bleController.bleStatus, perform: { newValue in
            bleController.addServices()
            freqMactcher.startListening()
        })
        .onChange(of: bleController.messageLabel) { newValue in
            
            if (newValue == "start") {
                isReady = true
                videoManager.changeStep(step: 1)
            }
            if (newValue == "reset") {
//                videoManager.player.rate = 1.0
//                videoManager.player.pause()
                videoManager.changeStep(step: 1)
                bleController.messageLabel = ""
            }
        }
        .onChange(of: freqMactcher.freqResult, perform: { newValue in
            if(videoManager.step < 7 && isReady){
                if (videoManager.currentTime < videoManager.timelimit) {
                    videoManager.player.rate *= 1.2
                }
                else {
                    videoManager.changeStep(step: videoManager.step + 1)
                }
            }
        })
        .onChange(of: videoManager.currentTime, perform: { newValue in
            print(newValue)
            if (newValue > videoManager.timelimit && videoManager.step < 7) {
                videoManager.player.rate = 1.0
                videoManager.player.pause()
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


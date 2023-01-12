//
//  ContentView.swift
//  Symbiose_macos_act1
//
//  Created by Jonathan Pegaz on 09/01/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var videoManager:VideoManager = VideoManager()
    @StateObject var bleController:BLEController = BLEController()
    
    @State var act1ok:Bool = false
    
    var body: some View {
        VStack {
            PlayerView(player: videoManager.player)
            Button("step 2"){
                videoManager.changeStep(step: 2)
            }
            Button("step 3"){
                videoManager.changeStep(step: 3)
            }
            Button("step 4"){
                videoManager.changeStep(step: 4)
            }
            Button("step 5"){
                videoManager.changeStep(step: 5)
            }
            Button("step 6"){
                videoManager.changeStep(step: 6)
                bleController.sendEndValue()
            }
            Button("step 7"){
                videoManager.changeStep(step: 7)
            }
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
                FrequencyMatcher.instance.startListening()
            }
        }
        .onChange(of: FrequencyMatcher.instance.freqResult, perform: { newValue in
            print("\(newValue) Hz")
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


//
//  ContentView.swift
//  Symbiose_macos_act1
//
//  Created by Jonathan Pegaz on 09/01/2023.
//

import SwiftUI

// Add this to the top of our ContentView.swift file.
//let numberOfSamples: Int = 10
//
//struct BarView: View {
//   // 1
//    var value: CGFloat
//
//    var body: some View {
//        ZStack {
//           // 2
//            RoundedRectangle(cornerRadius: 20)
//                .fill(LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
//                                     startPoint: .top,
//                                     endPoint: .bottom))
//                // 3
//                .frame(width: (200 - CGFloat(numberOfSamples) * 4) / CGFloat(numberOfSamples), height: value)
//        }
//    }
//}

struct ContentView: View {
    @StateObject var BLEactios:BLEObservableIos = BLEObservableIos()
    @StateObject var videoManager:VideoManager = VideoManager()
    @StateObject var bleController:BLEController = BLEController()
    
    @StateObject var audioSpectrogram:AudioSpectrogram = AudioSpectrogram()
    
    @State var act1ok:Bool = false
    
//    @ObservedObject private var mic = MicrophoneMonitor(numberOfSamples: numberOfSamples)
    
//    private func normalizeSoundLevel(level: Float) -> CGFloat {
//            let level = max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 25
//
//            return CGFloat(level * (300 / 25)) // scaled to max at 300 (our height of our bar)
//        }
    
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
            }
            Button("step 7"){
                videoManager.changeStep(step: 7)
            }
            Text(BLEactios.connectedPeripheral?.name ?? "personne")
        }
        .padding()
        .onAppear(){
            bleController.load()
            FrequencyMatcher.instance.startListening()
            //audioSpectrogram.startRunning()
        }
        .onChange(of: bleController.bleStatus, perform: { newValue in
            BLEactios.startScann()
        })
        .onChange(of: BLEactios.connectedPeripheral, perform: { newValue in
            if let p = newValue{
                BLEactios.listen { r in
                    print(r)
                }
            }
        })
        .onChange(of: bleController.messageLabel) { newValue in
            if (newValue == "connected") {
                videoManager.changeStep(step: 1)
                audioSpectrogram.contentsGravity = .resize
                audioSpectrogram.startRunning()
            }
        }
        .onChange(of: audioSpectrogram.freqPomp) { newValue in
            
        }
        .onChange(of: videoManager.currentTime) { newValue in
            if (newValue > 50 && !act1ok) {
                BLEactios.sendString(str: "act1_ok")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


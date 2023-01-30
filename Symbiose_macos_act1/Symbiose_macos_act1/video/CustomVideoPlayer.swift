//
//  CustomVideoPLayer.swift
//  videomapping
//
//  Created by digital on 27/12/2022.
//

import Foundation
import AVKit
import SwiftUI

//struct CustomVideoPlayer: UIViewControllerRepresentable {
//
//    let controller = AVPlayerViewController()
//    let player:AVPlayer
//
//    init(player: AVPlayer) {
//        self.player = player
//    }
//
//    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        controller.player = player
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
//
//    }
//}

struct PlayerView: NSViewRepresentable {
    var player: AVPlayer

    func updateNSView(_ NSView: NSView, context: NSViewRepresentableContext<PlayerView>) {
        guard let view = NSView as? AVPlayerView else {
            debugPrint("unexpected view")
            return
        }

        view.player = player
        view.showsFullScreenToggleButton = true
//        view.enterFullScreenMode(.main!)
    }

    func makeNSView(context: Context) -> NSView {
        return AVPlayerView(frame: .zero)
    }
}

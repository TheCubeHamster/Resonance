//
//  SoundPlayer.swift
//  Taptronome
//
//  Created by Alex Xie on 4/20/25.
//

import SwiftUI
import Foundation
import AVFoundation

class SoundPlayer: ObservableObject {
    var player: AVAudioPlayer?

    func preloadSound(filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("Error: Could not find sound file")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch {
            print("Error: Could not create AVAudioPlayer")
        }
    }

    func playSound(vol: Float) {
        player?.stop()
        player?.volume = vol
        player?.play()
    }
}

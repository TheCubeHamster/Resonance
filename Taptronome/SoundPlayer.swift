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
    var dingPlayer: AVAudioPlayer?
    var bigClickPlayer: AVAudioPlayer?
    var smallClickPlayer: AVAudioPlayer?
    var smallClickAlt:AVAudioPlayer?
    var useAlt: Bool = false

    func preloadSounds() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            print("Error")
        }
        
        guard let dingTrimURL = Bundle.main.url(forResource: "dingTrim", withExtension: "mp3") else {
            print("Error: Could not find sound file")
            return
        }
        
        guard let bigClickURL = Bundle.main.url(forResource: "move-check", withExtension: "mp3") else {
            print("Error: Could not find sound file")
            return
        }
        
        guard let smallClickURL = Bundle.main.url(forResource: "move-self", withExtension: "mp3") else {
            print("Error: Could not find sound file")
            return
        }

        do {
            dingPlayer = try AVAudioPlayer(contentsOf: dingTrimURL)
            dingPlayer?.prepareToPlay()
            bigClickPlayer = try AVAudioPlayer(contentsOf: bigClickURL)
            bigClickPlayer?.prepareToPlay()
            smallClickPlayer = try AVAudioPlayer(contentsOf: smallClickURL)
            smallClickPlayer?.prepareToPlay()
            smallClickAlt = try AVAudioPlayer(contentsOf: smallClickURL)
            smallClickAlt?.prepareToPlay()
        } catch {
            print("Error: Could not create AVAudioPlayer")
        }
    }

    func playSound(sound: Int, vol: Float) {
        switch (sound) {
        case 0:
            dingPlayer?.volume = vol
            dingPlayer?.play()
            break
        case 1:
            bigClickPlayer?.volume = vol
            bigClickPlayer?.play()
            break
        case 2:
            if (!useAlt) {
                smallClickPlayer?.volume = vol
                smallClickPlayer?.play()
            } else {
                smallClickAlt?.volume = vol
                smallClickAlt?.play()
            }
            useAlt.toggle()
            break
        default:
            break
        }
    }
}

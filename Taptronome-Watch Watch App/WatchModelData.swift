//
//  ModelData.swift
//  Taptronome
//
//  Created by Alex Xie on 4/19/25.
//

import Foundation

@Observable
class WatchModelData {
    var bpm: Double = 120.0
    var isVibrating: Bool = false
    var currentBeat: Int = 0
    var timeSignature: [Int] = [4, 4] // Default to 4/4 time
    var subdivision: Int = 1 // Default to quarter note subdivision
}

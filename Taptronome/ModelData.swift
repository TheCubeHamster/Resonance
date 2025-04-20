//
//  ModelData.swift
//  Taptronome
//
//  Created by Alex Xie on 4/19/25.
//

import Foundation
import SwiftUI

struct beatIcon: Hashable {
    var index: Int
    var color: Color
    var filled: Color
    let id = UUID()
}

@Observable
class ModelData {
    var bpm: Double = 120.0
    var isVibrating: Bool = false
    var currentBeat: Int = 0
    var timeSignature: [Int] = [4, 4] // Default to 4/4 time
    var subdivisions: Int = 1
    
    var hue: Double = 162.0/360.0
    var saturation: Double = 0.61
    var startBrightness: Double = 0.67
    var endBrightness: Double = 0.25
    
    var beatIcons: [beatIcon] = []
    
    init() {
        generateBeatIcons()
    }
    
    func generateBeatIcons() {
        beatIcons.removeAll()
        for i in 0...timeSignature[0] {
            let icon = beatIcon(index: i, color: .primary, filled: .red)
            beatIcons.append(icon)
        }
    }
}



//
//  BeatVisualizer.swift
//  Taptronome
//
//  Created by Alex Xie on 4/19/25.
//

import SwiftUI

struct BeatVisualizer: View {
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(modelData.beatIcons, id: \.self) { circle in
                let radius = geometry.size.height * (0.3 + (CGFloat(circle.index) * 0.3 / CGFloat(modelData.timeSignature[0])))
                Circle()
                    .stroke(.white)
                    .fill(Color(hue: modelData.hue, saturation: modelData.saturation, brightness: circle.index <= modelData.currentBeat && circle.index != 0 ? modelData.startBrightness : 0.0))
//                    .hueRotation(Angle(degrees: modelData.hue))
//                    .saturation(modelData.saturation)
//                    .brightness(circle.index <= modelData.currentBeat ? modelData.startBrightness : 0)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 1.2 - radius)
                    .frame(width: radius * 2, height: radius * 2)
                    .shadow(color: .black, radius: 4, x: 0, y: 4)
                    .zIndex(Double(modelData.beatIcons.count - circle.index))
            }
        }
    }
}

#Preview {
    BeatVisualizer()
        .environment(ModelData())
}

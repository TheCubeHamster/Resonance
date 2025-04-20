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
                let prevRadius = geometry.size.height * (0.3 + (CGFloat(circle.index - 2) * 0.3 / CGFloat(modelData.timeSignature[0])))
                if (circle.index > 0) {
                    Circle()
                        .fill(Color(hue: modelData.hue, saturation: modelData.saturation, brightness: circle.index <= modelData.currentBeat ? modelData.startBrightness + (Double(circle.index) / Double(modelData.beatIcons.count) * (modelData.endBrightness - modelData.startBrightness)) : modelData.endBrightness * 0.5))
                    
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 1.2 - radius)
                        .frame(width: radius * 2, height: radius * 2)
                        .shadow(color: .black, radius: 10, x: 0, y: 4)
                        .zIndex(Double(modelData.beatIcons.count - circle.index))
                }
                else {
                    Circle()
                        .fill(Color(hue: 0, saturation: 0, brightness: 0.19))
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 1.2 - radius)
                        .frame(width: radius * 2, height: radius * 2)
                        .zIndex(Double(modelData.beatIcons.count - circle.index))
                }
                if (circle.index > 0) {
                    ForEach(0..<modelData.subDivisions[circle.index - 1], id: \.self) { index in
                        let offset = prevRadius + ((CGFloat(index + 1)) * (radius - prevRadius) / CGFloat(modelData.subDivisions[circle.index - 1] + 1))
                        if (modelData.currentBeat > circle.index) {
                            Circle()
                                .fill(.white)
                                .frame(width: 10, height: 10)
                                .position(x: geometry.size.width / 2, y: geometry.size.height * 1.2 - radius)
                                .offset(x: 0, y: -offset)
                                .zIndex(Double(modelData.beatIcons.count - circle.index))
                        }
                        else if (modelData.currentBeat == circle.index) {
                            Circle()
                                .fill(index < modelData.currentSubDivision ? .white : .white.opacity(0.2))
                                .frame(width: 10, height: 10)
                                .position(x: geometry.size.width / 2, y: geometry.size.height * 1.2 - radius)
                                .offset(x: 0, y: -offset)
                                .zIndex(Double(modelData.beatIcons.count - circle.index))
                        }
                        else {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 10, height: 10)
                                .position(x: geometry.size.width / 2, y: geometry.size.height * 1.2 - radius)
                                .offset(x: 0, y: -offset)
                                .zIndex(Double(modelData.beatIcons.count - circle.index))
                        }
                    }
                }
            }
        }
        .background(Color(hue: 0, saturation: 0, brightness: 0.19))
    }
}

#Preview {
    BeatVisualizer()
        .environment(ModelData())
}

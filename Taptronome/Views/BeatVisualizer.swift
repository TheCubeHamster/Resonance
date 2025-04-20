//
//  BeatVisualizer.swift
//  Taptronome
//
//  Created by Alex Xie on 4/19/25.
//

import SwiftUI

struct beatIcon: Identifiable {
    var index: Int
    var color: Color
    var filled: Color
    let id = UUID()
}

struct BeatVisualizer: View {
    @Environment(ModelData.self) var modelData
    @State private var beatCircles: [beatIcon] = [
        beatIcon(index: 0, color: .primary, filled: .red),
        beatIcon(index: 1, color: .primary, filled: .red),
        beatIcon(index: 2, color: .primary, filled: .red),
        beatIcon(index: 3, color: .primary, filled: .red),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(beatCircles) { circle in
                Circle()
                    .stroke(circle.index < modelData.currentBeat ? circle.filled : circle.color)
                    .position(x: geometry.size.width / 2, y: CGFloat(circle.index + 1) * geometry.size.height / CGFloat(modelData.timeSignature[0]) + (geometry.size.height * 0.3))
                    .frame(width: geometry.size.width * CGFloat(circle.index + 1), height: geometry.size.width * CGFloat(circle.index + 1))
            }
        }
    }
}

#Preview {
    BeatVisualizer()
        .environment(ModelData())
}

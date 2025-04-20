//
//  ContentView.swift
//  Taptronome
//
//  Created by Alex Xie on 4/19/25.
//

import SwiftUI
import WatchKit

struct BeatIcon : Hashable, Identifiable {
    let index: Int
    let hue: Double
    let saturation: Double
    let lowBrightness: Double
    let highBrightness: Double
    let id = UUID()
}

struct ContentView: View {
    @State private var timer: Timer?
    @State private var isVibrating: Bool = false
    @State private var timeSignature: [Int] = [4, 4]
    @State private var bpm: Double = 180
    @State private var subBeat: Int = 0
    @State private var circleBeat: Int = 0
    @State private var numCircles = 4
    
    @State private var baseHue: Double = 0.45
    @State private var baseSaturation: Double = 1.0
    @State private var baseBrightness: Double = 0.42

    var body: some View {
        // Create list of all circles
        let circles: [BeatIcon] = (0..<numCircles).map { index in
            let hue = baseHue
            let saturation = baseSaturation * (1 - Double(index) / Double(numCircles))
            let lowBrightness = 0.5 * baseBrightness * (1 - Double(index) / Double(numCircles))
            let highBrightness = baseBrightness * (1 - Double(index) / Double(numCircles))
            return BeatIcon(index: index, hue: hue, saturation: saturation, lowBrightness: lowBrightness, highBrightness: highBrightness)
        }
        let backgroundColor = Color(hue: baseHue, saturation: baseSaturation * (1 - Double(numCircles - 1) / Double(numCircles)), brightness: 0.2 * baseBrightness * (1 - Double(numCircles - 1) / Double(numCircles)))

        GeometryReader { geometry in
            ZStack {
                ForEach(circles, id: \.self) { circle in
                    let radius = CGFloat(circle.index + 1) * geometry.size.width / CGFloat(numCircles)
                    
                    if (circle.index == 0) {
                        Button(action: {
                            isVibrating.toggle()
                            WKInterfaceDevice.current().play(WKHapticType.success)
                            if isVibrating {
                                startVibration()
                            } else {
                                stopVibration()
                            }
                        }) {
                            Text("\(Int(bpm))")
                                .frame(width: radius, height: radius)
                                .foregroundColor(Color.white)
                                .background(Color(hue: circle.hue, saturation: circle.saturation, brightness: circleBeat > circle.index ? circle.highBrightness : circle.lowBrightness))
                                .clipShape(Circle())
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .buttonStyle(.plain)
                        .zIndex(Double(numCircles - circle.index))
                        .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 0)
                        .focusable()
                    } else {
                        Circle()
                            .fill(Color(hue: circle.hue, saturation: circle.saturation, brightness: circleBeat > circle.index ? circle.highBrightness : circle.lowBrightness))
                            .frame(width: radius, height: radius)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            .zIndex(Double(numCircles - circle.index))
                            .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 0)
                    }
                }
            }
            .focusable(true)
            .digitalCrownRotation($bpm, from: 60.0, through: 300.0, by: 1.0, sensitivity: .low, isHapticFeedbackEnabled: true)
            .onChange(of: timeSignature) {
                numCircles = timeSignature[0]
            }
        }
        .background(backgroundColor)
    }

    private func startVibration() {
        circleBeat = 0
        timer = Timer.scheduledTimer(withTimeInterval: Double(60.0) / Double(Int(bpm)), repeats: true) { _ in
            let click: WKHapticType
            circleBeat += 1
            if circleBeat >= timeSignature[1] {
                click = WKHapticType.start
                if (circleBeat >= numCircles) {
                    circleBeat = 0
                }
            } else {
                click = WKHapticType.click
            }
            WKInterfaceDevice.current().play(click)
        }
    }

    private func stopVibration() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ContentView()
}

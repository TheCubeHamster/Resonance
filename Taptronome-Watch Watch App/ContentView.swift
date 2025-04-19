//
//  ContentView.swift
//  Taptronome
//
//  Created by Alex Xie on 4/19/25.
//

import SwiftUI
import WatchKit



struct ContentView: View {
    @State private var isVibrating = false
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Button(action: {
                if isVibrating {
                    stopVibration()
                } else {
                    startVibration()
                }
            }) {
                Text(isVibrating ? "Stop" : "Start 120 BPM")
                    .padding()
                    .background(isVibrating ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }

    private func startVibration() {
        isVibrating = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let click = WKHapticType.click
            WKInterfaceDevice.current().play(click)
        }
    }

    private func stopVibration() {
        isVibrating = false
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ContentView()
}

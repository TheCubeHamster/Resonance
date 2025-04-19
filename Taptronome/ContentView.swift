//
//  ContentView.swift
//  Taptronome
//
//  Created by Alex Xie on 4/19/25.
//

import SwiftUI
import CoreHaptics



struct ContentView: View {
    @State private var engine: CHHapticEngine?
    @State private var isVibrating = false
    @State private var timer: Timer?
    @State private var bpm_global = 60.0
    @State private var isEditing = false
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func hardClick() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        //let curve = CHHapticParameterCurve(parameterID: .hapticSharpnessControl, controlPoints: [CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1), CHHapticParameterCurve.ControlPoint(relativeTime: 0.5, value: 0)], relativeTime: 0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.035)
        events.append(event)
        
        let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
        let end = CHHapticParameterCurve.ControlPoint(relativeTime: 0.035, value: 0)
        
        let curve = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, end], relativeTime: 0)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameterCurves: [curve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }

    var body: some View {
        VStack {
            Slider(
                value: $bpm_global,
                in: 30...300,
                step: 1,
                onEditingChanged: { editing in
                    isEditing = editing
                    updateBPM()
                }
            )
            Text("BPM: \(Int(bpm_global))")
                .foregroundColor(isEditing ? .red : .blue)
            Button(action: {
                if isVibrating {
                    stopVibration()
                } else {
                    startVibration()
                }
            }) {
                Text(isVibrating ? "Stop" : "Start")
                    .padding()
                    .background(isVibrating ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .onAppear(perform: prepareHaptics)
        }
        .padding()
    }

    private func startVibration() {
        isVibrating = true
        timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(Int(bpm_global)), repeats: true) { _ in
            hardClick()
        }
    }
    
    private func updateBPM() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(Int(bpm_global)), repeats: true) { _ in
            hardClick()
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

//
//  ContentView.swift
//  Taptronome
//
//  Created by Alex Xie on 4/19/25.
//

import SwiftUI
import CoreHaptics



struct ContentView: View {
    @Environment(ModelData.self) var modelData
    
    @State private var engine: CHHapticEngine?
    @State private var timer: Timer?
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
        let mid = CHHapticParameterCurve.ControlPoint(relativeTime: 0.02, value: 1)
        let end = CHHapticParameterCurve.ControlPoint(relativeTime: 0.035, value: 0)
        
        let curve = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, mid, end], relativeTime: 0)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameterCurves: [curve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
        
        if (modelData.currentBeat % modelData.timeSignature[1] == 0) {
            modelData.currentBeat = 1
        }
        else {
            modelData.currentBeat += 1
        }
            
    }

    var body: some View {
        @Bindable var modelData = modelData
        
        VStack {
            BeatVisualizer()
            Slider(
                value: $modelData.bpm,
                in: 30...300,
                step: 1,
                onEditingChanged: { editing in
                    isEditing = editing
                    if (modelData.isVibrating) {
                        updateBPM()
                    }
                }
            )
            Text("BPM: \(Int(modelData.bpm))")
                .foregroundColor(isEditing ? .red : .blue)
            Button(action: {
                if modelData.isVibrating {
                    stopVibration()
                } else {
                    startVibration()
                }
            }) {
                Text(modelData.isVibrating ? "Stop" : "Start")
                    .padding()
                    .background(modelData.isVibrating ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .onAppear(perform: prepareHaptics)
            Text("Current Beat: \(modelData.currentBeat)")
        }
        .padding()
    }

    private func startVibration() {
        modelData.currentBeat = 1
        modelData.isVibrating = true
        timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(Int(modelData.bpm)), repeats: true) { _ in
            hardClick()
        }
    }
    
    private func updateBPM() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(Int(modelData.bpm)), repeats: true) { _ in
            hardClick()
        }
    }

    private func stopVibration() {
        modelData.isVibrating = false
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}

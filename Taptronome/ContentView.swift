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
    // @State private var selection: TabView
    @State private var subTimer: Timer?
    @State private var isEditing = false
    @State private var isTimeSigEditing = false
    
    @StateObject private var ding = SoundPlayer()
    @StateObject private var bigClick = SoundPlayer()
    @StateObject private var smallClick = SoundPlayer()
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
        
        ding.preloadSound(filename: "dingTrim")
        bigClick.preloadSound(filename: "move-check")
        smallClick.preloadSound(filename: "move-self")
    }
    
    func hardClick() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(modelData.vibStrength))
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
        
        if (modelData.currentBeat == modelData.timeSignature[0]) {
            ding.playSound(vol: Float(modelData.volume))
        }
        else {
            bigClick.playSound(vol: Float(modelData.volume))
        }
        
        if (modelData.currentBeat % modelData.timeSignature[0] == 0) {
            modelData.currentBeat = 1
        }
        else {
            modelData.currentBeat += 1
        }
        
        modelData.currentSubDivision = 0
        
        subTimer?.invalidate()
        subTimer = nil
        subTimer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(Int(modelData.bpm)) / (Double(modelData.subDivisions[modelData.currentBeat - 1]) + 1.0), repeats: true) { _ in
            softClick()
        }
    }
    
    func softClick() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(modelData.vibStrength))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.035)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
        modelData.currentSubDivision += 1
        smallClick.playSound(vol: Float(modelData.volume))
    }

    var body: some View {
        @Bindable var modelData = modelData
        
        NavigationView {
            ZStack {
                BeatVisualizer()
                VStack {
                    Spacer()
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Text("\(Int(modelData.bpm))")
                            .padding()
                            .font(.system(size: 72))
                            .bold()
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.automatic)
                    .sheet(isPresented: $isEditing) {
                        bpmDial()
                            .environment(modelData)
                    }
                    .onChange(of: modelData.bpm) {
                        if (modelData.isVibrating) {
                            updateBPM()
                        }
                    }
                    
                    HStack {
                        // Time Signature Picker
                        Spacer()
                        Button(action: {
                            isTimeSigEditing.toggle()
                        }) {
                            Text("\(modelData.timeSignature[0])\n\(modelData.timeSignature[1])")
                                .font(Font.custom("Inter", size: 20).weight(.bold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .sheet(isPresented: $isTimeSigEditing) {
                            TimeSignaturePicker()
                        }
                        .onChange(of: modelData.timeSignature) {
                            modelData.generateBeatIcons()
                        }
//                        Text("Subdivision: \(modelData.currentSubDivision)")
//
//                        Spacer()
//                        Text("Volume: \(modelData.volume)")
//                        
//                        // Start/Stop Button
                        Spacer()
                        Button(action: {
                            modelData.isVibrating.toggle()
                        })
                        {
                            Text(modelData.isVibrating ? "Stop" : "Start")
                                .font(Font.custom("Inter", size: 20).weight(.bold))
                                .padding()
                                .frame(width: 150, height: 60)
                                .foregroundStyle(.white)
                                .background(.black)
                                .cornerRadius(50)
                        }
                        .onAppear(perform: prepareHaptics)
                        .onChange(of: modelData.isVibrating) {
                            if (modelData.isVibrating) {
                                startVibration()
                            } else {
                                stopVibration()
                            }
                        }
                        Spacer()

                        // Volume Control
                        NavigationLink(destination: ConfigSliders())
                        {
                            Image("sound_max")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40) // Adjust size as needed
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                    }
                    .padding(10)
                    
                    // Menu Bar
                    /*
                    TabView(padding: 25) {
                        ContentView() {
                            .tabItem {
                                Label("Music Selector", "music_icon")
                            }
                        }
                    }*/
                }
            }
        }
    }

    private func startVibration() {
        modelData.currentBeat = 1
        modelData.currentSubDivision = 0
        modelData.isVibrating = true
        timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(Int(modelData.bpm)), repeats: true) { _ in
            hardClick()
        }
    }
    
    private func updateBPM() {
        subTimer?.invalidate()
        subTimer = nil
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
        subTimer?.invalidate()
        subTimer = nil
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}

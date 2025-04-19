//
//  ContentView.swift
//  Taptronome
//
//  Created by Alex Xie on 4/19/25.
//

import SwiftUI

// Main ContentView with UI Controls
struct ContentView: View {
    @StateObject private var vibrationMetronome = CustomDurationVibration()
    @State private var showingSettings = false
    @State private var isEditingBPM = false
    @State public var bpm: Double = 120

    var body: some View {
        VStack(spacing: 30) {
            // Title
            Text("Pocket Metronome")
                .font(.largeTitle)
                .fontWeight(.bold)

            // BPM Display
            Text("\(Int(vibrationMetronome.bpm)) BPM")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .padding()
                .animation(.spring(), value: vibrationMetronome.bpm)

            // BPM Slider
            Slider(
                value: $vibrationMetronome.bpm,
                in: 40...240,
                step: 1,
                onEditingChanged: { editing in
                    isEditingBPM = editing
                    vibrationMetronome.updateBPM(newBPM: vibrationMetronome.bpm)
                })
                .padding(.horizontal)
                .accentColor(.blue)
                    

            // Tempo marking
            Text(tempoMarking(for: vibrationMetronome.bpm))
                .font(.headline)
                .foregroundColor(.secondary)

            Spacer()

            // Main Button
            Button(action: {
                vibrationMetronome.toggleMetronome()
            }) {
                Circle()
                    .fill(vibrationMetronome.isRunning ? Color.red : Color.green)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text(vibrationMetronome.isRunning ? "Stop" : "Start")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                    .shadow(radius: 5)
            }
            .padding(.bottom, 40)

            // Settings Button
            Button(action: {
                showingSettings = true
            }) {
                HStack {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .padding()
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(10)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }

            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }

    // Helper function to get tempo marking based on BPM
    func tempoMarking(for bpm: Double) -> String {
        switch bpm {
        case 40..<60:
            return "Largo"
        case 60..<66:
            return "Larghetto"
        case 66..<76:
            return "Adagio"
        case 76..<108:
            return "Andante"
        case 108..<120:
            return "Moderato"
        case 120..<168:
            return "Allegro"
        case 168..<200:
            return "Presto"
        case 200...:
            return "Prestissimo"
        default:
            return ""
        }
    }
}

//
//  SettingsView.swift
//  Taptronome
//
//  Created by Jordan Wong on 4/19/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var timeSignature: Int = 4
    @State private var accentFirstBeat: Bool = true
    @State private var vibrationStrength: Double = 0.8

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time Signature")) {
                    Picker("Beats per measure", selection: $timeSignature) {
                        ForEach(2..<13) { beats in
                            Text("\(beats)/4").tag(beats)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }

                Section(header: Text("Accents")) {
                    Toggle("Accent first beat", isOn: $accentFirstBeat)
                }

                Section(header: Text("Vibration")) {
                    Text("Strength: \(Int(vibrationStrength * 100))%")
                    Slider(value: $vibrationStrength)
                }

                Section(header: Text("About")) {
                    Text("Pocket Metronome uses haptic feedback to provide a silent metronome experience that you can feel rather than hear.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

//
//  Metronome.swift
//  Taptronome
//
//  Created by Jordan Wong on 4/19/25.
//

import CoreHaptics
import SwiftUI

class CustomDurationVibration: ObservableObject {
    private var hapticEngine: CHHapticEngine?
    private var metronomeTimer: Timer?
    private var vibrationTimer: Timer?
    private var isVibrating = false

    // Metronome state
    @Published var isRunning = false
    @Published var bpm: Double = 120

    init() {
        prepareHaptics()
    }

    /// Prepares the haptic engine
    private func prepareHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Failed to initialize haptic engine: \(error)")
        }
    }

    /// Vibrates for the exact specified duration
    /// - Parameter duration: Duration in seconds for the vibration
    func vibrate(duration: TimeInterval) {
        // Stop any ongoing vibration
        stopVibration()

        guard let hapticEngine = hapticEngine else {
            print("Haptic engine is not available.")
            return
        }

        do {
            // Create a haptic pattern for the specified duration
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: duration)

            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)

            // Start the vibration
            isVibrating = true
            try player.start(atTime: 0)

            // Use a timer to ensure vibration stops at the right time
            vibrationTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                self?.stopVibration()
            }
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }

    /// Stops any ongoing vibration
    func stopVibration() {
        if isVibrating {
            vibrationTimer?.invalidate()
            vibrationTimer = nil
            isVibrating = false
        }
    }

    /// Toggle metronome on/off
    func toggleMetronome() {
        if isRunning {
            stopMetronome()
        } else {
            startMetronome(bpm: bpm)
        }
    }

    /// Metronome functionality using custom duration vibrations
    /// - Parameters:
    ///   - bpm: Beats per minute
    ///   - vibrationDuration: How long each vibration should last (in seconds)
    ///   - accentPattern: Array of booleans where true means stronger vibration (accent)
    func startMetronome(bpm: Double, vibrationDuration: TimeInterval = 0.01, accentPattern: [Bool]? = nil) {
        stopMetronome()

        let beatInterval = 60.0 / bpm
        var currentBeat = 0
        let pattern = accentPattern ?? [true, false, false, false]

        isRunning = true

        metronomeTimer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            let isAccent = pattern[currentBeat % pattern.count]
            vibrate(duration: isAccent ? vibrationDuration * 1.5 : vibrationDuration)

            currentBeat = (currentBeat + 1) % pattern.count
        }

        vibrate(duration: vibrationDuration * 1.5)
    }
    
    // Updates the current BPM of the metronome to match the new BPM
    func updateBPM(newBPM: Double) {
        stopVibration()
        metronomeTimer?.invalidate()
        metronomeTimer = nil
        startMetronome(bpm: newBPM)
    }

    /// Stops the metronome
    func stopMetronome() {
        stopVibration()
        metronomeTimer?.invalidate()
        metronomeTimer = nil
        isRunning = false
    }

    deinit {
        stopMetronome()
    }
}

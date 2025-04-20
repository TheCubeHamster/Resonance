//
//  Taptronome_WatchApp.swift
//  Taptronome-Watch Watch App
//
//  Created by Alex Xie on 4/19/25.
//

import SwiftUI

@main
struct Taptronome_Watch_Watch_AppApp: App {
    @State private var modelData = ModelData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
        }
    }
}

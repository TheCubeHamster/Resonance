//
//  TaptronomeApp.swift
//  Taptronome
//
//  Created by Alex Xie on 4/19/25.
//

import SwiftUI

@main
struct TaptronomeApp: App {
    @State private var modelData = ModelData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ModelData())
        }
    }
}

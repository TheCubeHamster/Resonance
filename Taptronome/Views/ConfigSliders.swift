//
//  ConfigSliders.swift
//  Taptronome
//
//  Created by Alex Xie on 4/20/25.
//

import SwiftUI

struct ConfigSliders: View {
    @Environment(ModelData.self) var modelData
    @State private var selection: Tab = .volume
    
    enum Tab {
        case volume
        case haptics
    }

    var body: some View {
        @Bindable var modelData = modelData
        ZStack {
            GeometryReader { geometry in
                HStack {
                    if (selection == .volume) {
                        SlidePicker(value: $modelData.volume)
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.6)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                    else {
                        SlidePicker(value: $modelData.vibStrength)
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.6)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                    VStack {
                        Button(action: {
                            selection = .volume
                        }) {
                            Image("fontisto_music-note")
                                .opacity(selection == .volume ? 1.0 : 0.5)
                        }
                        .padding(.vertical)
                    
                        Button(action: {
                            selection = .haptics
                        }) {
                            Image("bi_phone-vibrate-fill")
                                .opacity(selection == .haptics ? 1.0 : 0.5)
                        }
                        .padding(.vertical)
                    }
                }
                .animation(.easeInOut)
            }
            .padding()
        }
        .background(Color(hue: 0, saturation: 0, brightness: 0.13))
    }
}

#Preview {
    ConfigSliders()
        .environment(ModelData())
}

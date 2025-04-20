//
//  TabBar.swift
//  Taptronome
//
//  Created by Alex Xie on 4/20/25.
//

import SwiftUI

struct TabBar: View {
    @Binding var selection: ContentView.Tab
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(hue: 0, saturation: 0, brightness: 0.34))
                .frame(height: 80)
                .cornerRadius(50)
            HStack {
                Button(action: {selection = .featured})
                {
                    Image("featured")
                        .opacity(selection == .featured ? 1.0 : 0.5)
                }
                Spacer()
                Button(action: {selection = .metronome})
                {
                    Image("metronome")
                        .opacity(selection == .metronome ? 1.0 : 0.5)
                }
                Spacer()
                Button(action: {selection = .settings})
                {
                    Image("settings")
                        .opacity(selection == .settings ? 1.0 : 0.5)
                }
            }
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    TabBar(selection: .constant(.featured))
}

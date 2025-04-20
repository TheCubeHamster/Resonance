//
//  Settings.swift
//  Taptronome
//
//  Created by Alex Xie on 4/20/25.
//

import SwiftUI

struct Settings: View {
    var body: some View {
        GeometryReader { geometry in
            Image("SettingsScreen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .offset(y: -100)
        }
    }
}

#Preview {
    Settings()
}

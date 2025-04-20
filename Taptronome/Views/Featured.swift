//
//  Featured.swift
//  Taptronome
//
//  Created by Alex Xie on 4/20/25.
//

import SwiftUI

struct Featured: View {
    var body: some View {
        GeometryReader { geometry in
            Image("SpotifySync")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .offset(y: -80)
        }
    }
}

#Preview {
    Featured()
}

//
//  TimeSignaturePicker.swift
//  Taptronome
//
//  Created by Jordan Wong on 4/20/25.
//

import SwiftUI

struct TimeSignaturePicker: View {
    let signatures = Array(1...12)
    let beats = [2, 4, 8]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 25) {
                        ForEach(signatures, id: \.self) { signature in
                            Text("\(signature)")
                                .font(.system(size: 88))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.clear)
                        }.ignoresSafeArea()
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(beats, id: \.self) { beat in
                            Text("\(beat)")
                                .font(.system(size: 88))
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.clear)
                        }.ignoresSafeArea()
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
            }
        }.background(Color(hue: 0, saturation: 0, brightness: 0.13))
        
    }
}

#Preview {
    TimeSignaturePicker()
}

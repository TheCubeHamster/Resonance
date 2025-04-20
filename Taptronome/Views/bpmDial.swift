//
//  bpmDial.swift
//  Taptronome
//
//  Created by Alex Xie on 4/19/25.
//

import SwiftUI

struct bpmDial: View {
    @Environment(ModelData.self) var modelData
    @State private var angleValue: Double = 0.0
    @State private var dAngle: Double = 0.0
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .stroke(.primary)
                        .strokeBorder(lineWidth: 7)
                    Circle()
                        .stroke(.primary)
                        .strokeBorder(lineWidth: 4)
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.9)
                    Circle()
                        .fill(.primary)
                        .frame(width: 30, height: 30)
                        .padding(10)
                        .offset(y: -geometry.size.width / 2)
                        .rotationEffect(.init(degrees: Double(angleValue)))
                        .gesture(DragGesture()
                            .onChanged(onDrag(value:))
                        )
                    Text("\(Int(modelData.bpm))")
                        .font(Font.custom("Instrument Sans", size: 72))
                        .bold()
                        .onChange(of: angleValue) { oldValue, newValue in
                            var delta: Double = 0.0
                            if (abs(newValue - oldValue) > 270) {
                                delta = abs(newValue - oldValue) - 360
                                delta = (newValue > oldValue) ? delta : -delta
                            }
                            else {
                                delta = newValue - oldValue
                            }
                            dAngle += delta
                            if (dAngle > 5) {
                                if (modelData.bpm < 300) {
                                    modelData.bpm += 1
                                }
                                dAngle -= 5
                            }
                            else if (dAngle < -5) {
                                if (modelData.bpm > 60) {
                                    modelData.bpm -= 1
                                }
                                dAngle += 5
                            }
                        }
                }
            }
            .sensoryFeedback(.selection, trigger: modelData.bpm)
            .padding()
            
        }
    }
    
    func onDrag(value: DragGesture.Value) {
        // calculating radians...
        
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        
        
        // since atan2 will give from -180 to 180...
        // eliminating drag gesture size
        // size = 55 => Radius = 27.5...
        
        let radians = atan2(vector.dy - 15, vector.dx - 15)
            
        // converting to angle...
        var angle = radians * 180 / .pi
        // simple technique for 0 to 360...
        // eg = 360 - 176 = 184..

        if angle < 0{
            angle = 360 + angle
        }
                
        if angle <  360 {
            angleValue = Double(angle) + 90
        }
    }
    func correction(oldValue: CGFloat) -> CGFloat {
        return oldValue * 300 + 200
    }
}

#Preview {
    bpmDial()
        .environment(ModelData())
}

//
//  ContentView.swift
//  RotaryKnobExample
//
//  Created by Danny Sung on 4/24/24.
//

import SwiftUI
import MHRotaryKnob

struct ContentView: View {
    @State var sliderValue: Double = 20
    @State var rotaryKnobConfig = MHRotaryKnobConfiguration(
        backgroundImage: Image("Knob Background"),
        knobImageNormal: Image("Knob"),
        knobImageDisabled: Image("Knob Disabled"),
        knobImageHighlighted: Image("Knob Highlighted"),
        knobImageCenter: CGPoint(x: 80.0, y: 76.0)
    )

    var body: some View {
        VStack {

            Slider(value: $sliderValue, in: 10...30, step: 0.2)
            Text("Drag the slider or turn the knob")

            MHRotaryKnobView(rotaryKnobConfig, size: CGSize(width: 160, height: 160))

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .background(Color.gray)
        .padding()
        .onChange(of: sliderValue, initial: false, { oldValue, newValue  in
            print("new slider value: \(newValue) ")
        })
    }
}

#Preview {
    ContentView()
}

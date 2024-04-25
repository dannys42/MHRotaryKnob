//
//  ContentView.swift
//  RotaryKnobExample
//
//  Created by Danny Sung on 4/24/24.
//

import SwiftUI

struct ContentView: View {
    @State var sliderValue: Double = 20

    var body: some View {
        VStack {

            Slider(value: $sliderValue, in: 10...30, step: 0.2) { didChange in

                print("changed: \(didChange)")
            }
            Text("Drag the slider or turn the knob")

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

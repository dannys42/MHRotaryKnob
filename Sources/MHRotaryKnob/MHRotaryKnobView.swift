//
//  MHRotaryKnobView.swift
//
//
//  Created by Danny Sung on 4/24/24.
//

import Foundation
import SwiftUI

struct MHRotaryKnobRepresentable: UIViewRepresentable {
    @ObservedObject var config: MHRotaryKnobConfiguration

    /*
    self.rotaryKnob.interactionStyle = MHRotaryKnobInteractionStyleRotating;
    self.rotaryKnob.scalingFactor = 1.5;
    self.rotaryKnob.maximumValue = self.slider.maximumValue;
    self.rotaryKnob.minimumValue = self.slider.minimumValue;
    self.rotaryKnob.value = self.slider.value;
    self.rotaryKnob.defaultValue = self.rotaryKnob.value;
    self.rotaryKnob.resetsToDefault = YES;
    self.rotaryKnob.backgroundColor = [UIColor clearColor];
    self.rotaryKnob.backgroundImage = [UIImage imageNamed:@"Knob Background"];
    [self.rotaryKnob setKnobImage:[UIImage imageNamed:@"Knob"] forState:UIControlStateNormal];
    [self.rotaryKnob setKnobImage:[UIImage imageNamed:@"Knob Highlighted"] forState:UIControlStateHighlighted];
    [self.rotaryKnob setKnobImage:[UIImage imageNamed:@"Knob Disabled"] forState:UIControlStateDisabled];
    self.rotaryKnob.knobImageCenter = CGPointMake(80.0, 76.0);
    [self.rotaryKnob addTarget:self action:@selector(rotaryKnobDidChange) forControlEvents:UIControlEventValueChanged];
*/
    func makeUIView(context: Context) -> MHRotaryKnob{
        let rotaryKnob = MHRotaryKnob()

        updateProperties(rotaryKnob: rotaryKnob)
        return rotaryKnob
    }

    func updateUIView(_ rotaryKnob: MHRotaryKnob, context: Context) {
        updateProperties(rotaryKnob: rotaryKnob)
    }

    @MainActor
    private func updateProperties(rotaryKnob: MHRotaryKnob) {
        rotaryKnob.interactionStyle = config.interactionStyle
        rotaryKnob.scalingFactor = config.scalingFactor
        rotaryKnob.backgroundColor = UIColor(config.backgroundColor)

        rotaryKnob.backgroundImage = config.backgroundImage?.asUIImage()
        rotaryKnob.foregroundImage = config.foregroundImage?.asUIImage()
        rotaryKnob.setKnobImage(config.knobImageNormal?.asUIImage(), for: .normal)
        rotaryKnob.setKnobImage(config.knobImageHighlighted?.asUIImage(), for: .highlighted)
        rotaryKnob.setKnobImage(config.knobImageDisabled?.asUIImage(), for: .disabled)
        rotaryKnob.minimumValue = config.minimumValue
        rotaryKnob.maximumValue = config.maximumValue
        rotaryKnob.defaultValue = config.defaultValue
        rotaryKnob.resetsToDefault = config.resetsToDefault
        rotaryKnob.continuous = config.continuous
        rotaryKnob.maxAngle = config.maxAngle
        rotaryKnob.minRequiredDistanceFromKnobCenter = config.minRequiredDistanceFromKnobCenter
        rotaryKnob.circularTouchZone = config.circularTouchZone
    }
}

public struct MHRotaryKnobView: View {
    @ObservedObject var configuration: MHRotaryKnobConfiguration

    public init(_ configuration: MHRotaryKnobConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        MHRotaryKnobRepresentable(config: configuration)
    }
}

public class MHRotaryKnobConfiguration: ObservableObject {
    @Published public var interactionStyle: MHRotaryKnobInteractionStyle = .rotating
    @Published public var scalingFactor: CGFloat = 1.0
    @Published public var backgroundColor: Color = Color(white: 0.0, opacity: 0.0)
    @Published public var backgroundImage: Image?
    @Published public var foregroundImage: Image?
    @Published public var knobImageNormal: Image?
    @Published public var knobImageDisabled: Image?
    @Published public var knobImageHighlighted: Image?
    @Published public var knobImageCenter: CGPoint = .zero
    @Published public var minimumValue: CGFloat = 0.0
    @Published public var maximumValue: CGFloat = 1.0
    @Published public var defaultValue: CGFloat = 0.5
    @Published public var resetsToDefault: Bool = true
    @Published public var continuous: Bool = true
    @Published public var maxAngle: CGFloat = 135
    @Published public var minRequiredDistanceFromKnobCenter: CGFloat = 4
    @Published public var circularTouchZone: Bool = false

    public init() {
    }
}


fileprivate extension View {
    @MainActor 
    func asUIImage(scale displayScale: CGFloat = 1.0) -> UIImage? {
        let renderer = ImageRenderer(content: self)

        renderer.scale = displayScale

        return renderer.uiImage
    }

}

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

    func makeUIView(context: Context) -> MHRotaryKnob {
        let rotaryKnob = MHRotaryKnob(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

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
    @Published public var interactionStyle: MHRotaryKnobInteractionStyle
    @Published public var scalingFactor: CGFloat
    @Published public var backgroundColor: Color
    @Published public var backgroundImage: Image?
    @Published public var foregroundImage: Image?
    @Published public var knobImageNormal: Image?
    @Published public var knobImageDisabled: Image?
    @Published public var knobImageHighlighted: Image?
    @Published public var knobImageCenter: CGPoint
    @Published public var minimumValue: CGFloat
    @Published public var maximumValue: CGFloat
    @Published public var defaultValue: CGFloat
    @Published public var resetsToDefault: Bool
    @Published public var continuous: Bool
    @Published public var maxAngle: CGFloat
    @Published public var minRequiredDistanceFromKnobCenter: CGFloat
    @Published public var circularTouchZone: Bool

    public init(interactionStyle: MHRotaryKnobInteractionStyle = .rotating,
                scalingFactor: CGFloat = 1.0,
                backgroundColor: Color = Color(white: 0.0, opacity: 0.0),
                backgroundImage: Image? = nil,
                foregroundImage: Image? = nil,
                knobImageNormal: Image? = nil,
                knobImageDisabled: Image? = nil,
                knobImageHighlighted: Image? = nil,
                knobImageCenter: CGPoint = .zero,
                minimumValue: CGFloat = 0.0,
                maximumValue: CGFloat = 1.0,
                defaultValue: CGFloat = 0.5,
                resetsToDefault: Bool = true,
                continuous: Bool = true,
                maxAngle: CGFloat = 135,
                minRequiredDistanceFromKnobCenter: CGFloat = 4,
                circularTouchZone: Bool = false) {

        self.interactionStyle = interactionStyle
        self.scalingFactor = scalingFactor
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.foregroundImage = foregroundImage
        self.knobImageNormal = knobImageNormal
        self.knobImageDisabled = knobImageDisabled
        self.knobImageHighlighted = knobImageHighlighted
        self.knobImageCenter = knobImageCenter
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.defaultValue = defaultValue
        self.resetsToDefault = resetsToDefault
        self.continuous = continuous
        self.maxAngle = maxAngle
        self.minRequiredDistanceFromKnobCenter = minRequiredDistanceFromKnobCenter
        self.circularTouchZone = circularTouchZone
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

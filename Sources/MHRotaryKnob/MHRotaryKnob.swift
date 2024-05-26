//  Converted to Swift 5.9.2 by Swiftify v5.9.29897 - https://swiftify.com/
/*
 * UIControl subclass that acts like a rotary knob.
 *
 * Copyright (c) 2010-2014 Matthijs Hollemans
 *
 * With contributions from Tim Kemp (slider-style tracking).
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import QuartzCore
import UIKit

/**
 * Possible values for the rotary knob's interactionStyle property.
 */
public enum MHRotaryKnobInteractionStyle {
    case rotating
    case sliderHorizontal // left -, right +
    case sliderVertical // up +, down -
}

/**
 * A rotary knob control.
 *
 * Operation of this control is similar to a UISlider. You can set a minimum,
 * maximum, and current value. When the knob is turned the control sends out
 * a UIControlEventValueChanged notification to its target-action.
 *
 * The interactionStyle property determines the way the control is operated.
 * It can be configured to act like a knob that must be turned, or to act like
 * a horizontal or vertical slider.
 *
 * The control uses two images, one for the background and one for the knob.
 * The background image is optional but you must set at least the knob image
 * before you can use the control.
 *
 * When double-tapped, the control resets to its default value, typically the
 * the center or minimum position. This feature can be disabled with the
 * resetsToDefault property.
 *
 * Because users will want to see what happens under their fingers, you are
 * advised not to make the knob smaller than 120x120 points. Because of this,
 * rotary knob controls probably work best on an iPad.
 *
 * This class needs the QuartzCore framework.
 */

public class MHRotaryKnob: UIControl {
    private var backgroundImageView: UIImageView? // shows the background image
    private var foregroundImageView: UIImageView? // shows the foreground image
    
    // Need to handle in this way so that UIImageView has the correct bounds.
    private var _knobImageView: UIImageView?
    private var knobImageView: UIImageView! // shows the knob image
    {
        get {
            return updateKnobImageViewIfNecessary()
        }
    }

    @discardableResult
    func updateKnobImageViewIfNecessary() -> UIImageView {
        var image: UIImage?
        if let _knobImageView {
            if _knobImageView.bounds == self.bounds {
                return _knobImageView
            }
            image = _knobImageView.image
            _knobImageView.removeFromSuperview()
        }
        let imageView = UIImageView(frame: self.bounds)
        imageView.image = image
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
//        imageView.sizeToFit()
        self.addConstraints([
            .init(item: self, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .top, multiplier: 1.0, constant: 0.0),
            .init(item: self, attribute: .left, relatedBy: .equal, toItem: imageView, attribute: .left, multiplier: 1.0, constant: 0.0),
            .init(item: self, attribute: .right, relatedBy: .equal, toItem: imageView, attribute: .right, multiplier: 1.0, constant: 0.0),
            .init(item: self, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
        ])

        _knobImageView = imageView
        return imageView
    }

    private var knobImageNormal: UIImage? // knob image for normal state
    private var knobImageHighlighted: UIImage? // knob image for highlighted state
    private var knobImageDisabled: UIImage? // knob image for disabled state
 // for tracking touches
    private var touchOrigin = CGPoint.zero // for horizontal/vertical tracking
    private var canReset = false // prevents reset while still dragging

    /// How the user interacts with the control.
    public var interactionStyle: MHRotaryKnobInteractionStyle = .rotating

    #if false
    private var touchPoint: CGPoint? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        let cg = UIGraphicsGetCurrentContext()!
        if let touchPoint {
            let radius: CGFloat = 10
            let r = CGRect(x: touchPoint.x - radius, y: touchPoint.y - radius, width: radius*2, height: radius*2)
            cg.setLineWidth(4)
            cg.setStrokeColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
            cg.strokeEllipse(in: r)
        }

        cg.setLineWidth(2.0)
        cg.setStrokeColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5))
        cg.stroke(self.bounds)
    }
    #endif

    /// The image that is drawn behind the knob. May be nil.
    public var backgroundImage: UIImage? {
        get {
            return backgroundImageView?.image
        }
        set(image) {
            if backgroundImageView == nil {
                backgroundImageView = UIImageView(frame: bounds)
                if let backgroundImageView {
                    addSubview(backgroundImageView)
                    sendSubviewToBack(backgroundImageView)
                }
            }

            backgroundImageView?.image = image
        }
    }

    /**
     * The image that is drawn on top of the knob. May be nil. This is useful
     * for partially transparent overlays to make shadow or highlight effects.
     */
    public var foregroundImage: UIImage? {
        get {
            return foregroundImageView?.image
        }
        set(image) {
            if foregroundImageView == nil {
                foregroundImageView = UIImageView(frame: bounds)
                if let foregroundImageView {
                    addSubview(foregroundImageView)
                    bringSubviewToFront(foregroundImageView)
                }
            }

            foregroundImageView?.image = image
        }
    }

    /// The image currently being used to draw the knob.
    public var currentKnobImage: UIImage? {
        return knobImageView?.image
    }

    /// For positioning the knob image.
    public var knobImageCenter: CGPoint {
        get {
            return knobImageView?.center ?? CGPoint.zero
        }
        set(theCenter) {
            knobImageView?.center = theCenter
        }
    }

    /// The maximum value of the control. Default is 1.0.
    public var maximumValue: CGFloat = 0.0

    /// The minimum value of the control. Default is 0.0.
    public var minimumValue: CGFloat = 0.0

    /// The control's current value. Default is 0.5 (center position).
    private var _value: CGFloat = 0.0
    public var value: CGFloat {
        get {
            _value
        }
        set(newValue) {
            setValue(Float(newValue), animated: false)
        }
    }

    /// The control's default value. Default is 0.5 (center position).
    public var defaultValue: CGFloat = 0.0

    /**
     * Whether the control resets to the default value on a double tap.
     * Default is YES.
     */
    public var resetsToDefault = false

    /**
     * Whether changes in the knob's value generate continuous update events.
     * If NO, the control only sends an action event when the user releases the
     * knob. The default is YES.
     */
    public var continuous = false

    /**
     * How many points of movement result in a one degree rotation in the knob's
     * position. Only used in the horizontal/vertical slider modes. Default is 1.
     */
    public var scalingFactor: CGFloat = 0.0

    /**
     * Get current knob angle.
     */
    public var angle: CGFloat {
        get {
            self.angle(forValue: value)
        }
        set {
            self.value = self.value(forAngle: newValue)
        }
    }

    /**
     * How far the knob can rotate to either side. Default is 135.0 degrees.
     */
    public var maxAngle: CGFloat = 0.0

    /**
     * How far away touches must be from the center of the knob in order to be
     * recognized. Default is 4 points.
     */
    public var minRequiredDistanceFromKnobCenter: CGFloat = 0.0

    /**
     * Whether the accepted touch area is contained within the bounding circle of the view.
     * The default is NO to be compatible with previous versions.
     */
    public var circularTouchZone = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        minimumValue = 0.0
        maximumValue = 1.0
        defaultValue = 0.5
        value = defaultValue
        angle = 0.0
        continuous = true
        resetsToDefault = true
        scalingFactor = 1.0
        maxAngle = 135.0
        minRequiredDistanceFromKnobCenter = 4.0

        valueDidChange(from: value, to: value, animated: false)
    }

    // MARK: - Data Model

    func clampAngle(_ angle: CGFloat) -> CGFloat {
        if angle < -maxAngle {
            return -maxAngle
        } else if angle > maxAngle {
            return maxAngle
        } else {
            return angle
        }
    }

    func angle(forValue value: CGFloat) -> CGFloat {
        return ((value - minimumValue) / (maximumValue - minimumValue) - 0.5) * (maxAngle * 2.0)
    }

    func value(forAngle angle: CGFloat) -> CGFloat {
        return (angle / (maxAngle * 2.0) + 0.5) * (maximumValue - minimumValue) + minimumValue
    }

    func angleBetweenCenterAndPoint(_ point: CGPoint) -> CGFloat {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        // Yes, the arguments to atan2() are in the wrong order. That's because
        // our coordinate system is turned upside down and rotated 90 degrees.
        let angle: CGFloat = atan2(point.x - center.x, center.y - point.y) * 180.0 / .pi

        return clampAngle(angle)
    }

    func squaredDistance(toCenter point: CGPoint) -> CGFloat {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let dx = point.x - center.x
        let dy = point.y - center.y
        return dx * dx + dy * dy
    }

    func shouldIgnoreTouch(at point: CGPoint) -> Bool {
        let minDistanceSquared = minRequiredDistanceFromKnobCenter * minRequiredDistanceFromKnobCenter
        if circularTouchZone {
            let distanceToCenter = squaredDistance(toCenter: point)
            if distanceToCenter < minDistanceSquared {
                return true
            }

            var maxDistanceSquared: CGFloat = Double(min(bounds.size.width, bounds.size.height)) / 2.0
            maxDistanceSquared *= maxDistanceSquared
            if distanceToCenter > maxDistanceSquared {
                return true
            }
        } else {
            if squaredDistance(toCenter: point) < minDistanceSquared {
                return true
            }
        }
        return false
    }

    func value(forPosition point: CGPoint) -> CGFloat {
        var delta: CGFloat
        if interactionStyle == .sliderVertical /* up +, down - */ {
            delta = touchOrigin.y - point.y
        } else {
            delta = point.x - touchOrigin.x
        }

        var newAngle = delta * scalingFactor + angle
        newAngle = clampAngle(newAngle)
        return value(forAngle: newAngle)
    }

    /**
     * Sets the controls’s current value, allowing you to animate the change
     * visually.
     */
    public func setValue(_ newValue: Float, animated: Bool) {
        let oldValue = _value

        if CGFloat(newValue) < minimumValue {
            _value = minimumValue
        } else if CGFloat(newValue) > maximumValue {
            _value = maximumValue
        } else {
            _value = CGFloat(newValue)
        }

        valueDidChange(from: oldValue, to: value, animated: animated)
    }

    public override var isEnabled: Bool {
        didSet {
            if !self.isEnabled {
                showDisabledKnobImage()
            } else if isHighlighted {
                showHighlighedKnobImage()
            } else {
                showNormalKnobImage()
            }
        }
    }

    // MARK: - Touch Handling

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)

        if interactionStyle == .rotating {
            // If the touch is too close to the center, we can't calculate a decent
            // angle and the knob becomes too jumpy.
            if shouldIgnoreTouch(at: point) {
                return false
            }

            // Calculate starting angle between touch and center of control.
            angle = angleBetweenCenterAndPoint(point)
        } else {
            touchOrigin = point
            angle = angle(forValue: value)
        }

        isHighlighted = true
        showHighlighedKnobImage()
        canReset = false

        return true
    }

    @discardableResult
    func handle(_ touch: UITouch?) -> Bool {
        guard let touch else {
//            self.touchPoint = nil
            value = value(forPosition: .zero)
            return true
        }

        if touch.tapCount > 1 && resetsToDefault && canReset {
            setValue(Float(defaultValue), animated: true)
            return false
        }

        let point = touch.location(in: self)
//        self.touchPoint = point

        if interactionStyle == .rotating {
            if shouldIgnoreTouch(at: point) {
                return false
            }

            // Calculate how much the angle has changed since the last event.
            let newAngle = angleBetweenCenterAndPoint(point)
            let delta = newAngle - angle
            angle = newAngle

            // We don't want the knob to jump from minimum to maximum or vice versa
            // so disallow huge changes.
            if abs(Float(delta)) > 45.0 {
                return false
            }

            let newValue = value + (maximumValue - minimumValue) * delta / (maxAngle * 2.0)
            self.setValue(Float(newValue), animated: true)

            // Note that the above is equivalent to:
            //self.value += [self valueForAngle:newAngle] - [self valueForAngle:angle];
        } else {
            let newValue = value(forPosition: point)
            value = newValue
        }

        return true
    }

    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if handle(touch) && continuous {
            sendActions(for: .valueChanged)
        }

        return true
    }

    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        isHighlighted = false
        showNormalKnobImage()

        // You can only reset the knob's position if you immediately stop dragging
        // the knob after double-tapping it, i.e. when tracking ends.
        canReset = true

        handle(touch)
        sendActions(for: .valueChanged)
    }

    public override func cancelTracking(with event: UIEvent?) {
        isHighlighted = false
        showNormalKnobImage()
    }

    // MARK: - Visuals

    func valueDidChange(from oldValue: CGFloat, to newValue: CGFloat, animated: Bool) {

        // (If you want to do custom drawing, then this is the place to do so.)

        let newAngle = angle(forValue: newValue)

        guard let knobImageView else {
            return
        }

        if animated {
            // We cannot simply use UIView's animations because they will take the
            // shortest path, but we always want to go the long way around. So we
            // set up a keyframe animation with three keyframes: the old angle, the
            // midpoint between the old and new angles, and the new angle.

            let oldAngle = angle(forValue: oldValue)

            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.duration = 0.2

            animation.values = [
                NSNumber(value: Float(oldAngle * Double.pi / 180.0)),
                NSNumber(value: Float((newAngle + oldAngle) / 2.0 * Double.pi / 180.0)),
                NSNumber(value: Float(newAngle * Double.pi / 180.0))
            ]

            animation.keyTimes = [NSNumber(value: 0.0), NSNumber(value: 0.5), NSNumber(value: 1.0)]

            animation.timingFunctions = [
                CAMediaTimingFunction(name: .easeIn),
                CAMediaTimingFunction(name: .easeOut)
            ]

            knobImageView.layer.add(animation, forKey: nil)
        }

        knobImageView.transform = CGAffineTransform(rotationAngle: newAngle * .pi / 180.0)
    }

    /**
     * Assigns a knob image to the specified control states.
     *
     * This image should have its position indicator at the top. The knob image is
     * rotated when the control's value changes, so it's best to make it perfectly
     * round.
     */
    public func setKnobImage(_ image: UIImage?, for theState: UIControl.State) {
        updateKnobImageViewIfNecessary()

        if theState == .normal {
            if image != knobImageNormal {
                knobImageNormal = image

                if state == .normal {
                    knobImageView.image = image
                    knobImageView.sizeToFit()
                }
            }
        }

        if theState.rawValue & UIControl.State.highlighted.rawValue != 0 {
            if image != knobImageHighlighted {
                knobImageHighlighted = image

                if state.rawValue & UIControl.State.highlighted.rawValue != 0 {
                    knobImageView?.image = image
                }
            }
        }

        if theState.rawValue & UIControl.State.disabled.rawValue != 0 {
            if image != knobImageDisabled {
                knobImageDisabled = image

                if state.rawValue & UIControl.State.disabled.rawValue != 0 {
                    knobImageView?.image = image
                }
            }
        }
    }

    /**
     * Returns the thumb image associated with the specified control state.
     */
    public func knobImage(for theState: UIControl.State) -> UIImage? {
        if theState == .normal {
            return knobImageNormal
        } else if theState.rawValue & UIControl.State.highlighted.rawValue != 0 {
            return knobImageHighlighted
        } else if theState.rawValue & UIControl.State.disabled.rawValue != 0 {
            return knobImageDisabled
        } else {
            return nil
        }
    }

    func showNormalKnobImage() {
        knobImageView?.image = knobImageNormal
    }

    func showHighlighedKnobImage() {
        if knobImageHighlighted != nil {
            knobImageView?.image = knobImageHighlighted
        } else {
            knobImageView?.image = knobImageNormal
        }
    }

    func showDisabledKnobImage() {
        if knobImageDisabled != nil {
            knobImageView?.image = knobImageDisabled
        } else {
            knobImageView?.image = knobImageNormal
        }
    }
}

/*
    For our purposes, it's more convenient if we put 0 degrees at the top,
    negative degrees to the left (the minimum is -self.maxAngle), and positive
    to the right (the maximum is +self.maxAngle).
 */

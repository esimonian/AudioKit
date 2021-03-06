//
//  AKADSRView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 8/3/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable open class AKADSRView: UIView {
    public typealias ADSRCallback = (Double, Double, Double, Double)->()

    @IBInspectable open var attackDuration: Double  = 0.100
    @IBInspectable open var decayDuration: Double   = 0.100
    @IBInspectable open var sustainLevel: Double    = 0.50
    @IBInspectable open var releaseDuration: Double = 0.100

    var attackTime: CGFloat {
        get {
            return CGFloat(attackDuration * 1000.0)
        }
        set {
            attackDuration = Double(newValue / 1000.0)
        }
    }
    var decayTime: CGFloat {
        get {
            return CGFloat(decayDuration * 1000.0)
        }
        set {
            decayDuration = Double(newValue / 1000.0)
        }
    }
    
    var sustainPercent: CGFloat {
        get {
            return CGFloat(sustainLevel * 100.0)
        }
        set {
            sustainLevel = Double(newValue / 100.0)
        }
    }

    var releaseTime: CGFloat {
        get {
            return CGFloat(releaseDuration * 1000.0)
        }
        set {
            releaseDuration = Double(newValue / 1000.0)
        }
    }

    var decaySustainTouchAreaPath = UIBezierPath()
    var attackTouchAreaPath       = UIBezierPath()
    var releaseTouchAreaPath      = UIBezierPath()

    open var callback: ADSRCallback?
    var currentDragArea = ""

    //// Color Declarations
    @IBInspectable open var attackColor: UIColor  = UIColor(red: 0.767, green: 0.000, blue: 0.000, alpha: 1.000)
    @IBInspectable open var decayColor: UIColor   = UIColor(red: 0.942, green: 0.648, blue: 0.000, alpha: 1.000)
    @IBInspectable open var sustainColor: UIColor = UIColor(red: 0.320, green: 0.800, blue: 0.616, alpha: 1.000)
    @IBInspectable open var releaseColor: UIColor = UIColor(red: 0.720, green: 0.519, blue: 0.888, alpha: 1.000)
    let bgColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
    
    @IBInspectable open var curveStrokeWidth: CGFloat = 1
    @IBInspectable open var curveColor: UIColor = UIColor.black


    var lastPoint = CGPoint.zero
    
    // MARK: - Initialization
    
    public init(callback: ADSRCallback? = nil) {
        self.callback = callback
        super.init(frame: CGRect(x: 0, y: 0, width: 440, height: 150))
        backgroundColor = UIColor.white
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Storyboard Rendering
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }
    
    override open var intrinsicContentSize : CGSize {
        return CGSize(width: 440, height: 150)
    }
    
    open class override var requiresConstraintBasedLayout : Bool {
        return true
    }
    
    // MARK: - Touch Handling
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            
            if decaySustainTouchAreaPath.contains(touchLocation) {
                currentDragArea = "ds"
            }
            if attackTouchAreaPath.contains(touchLocation) {
                currentDragArea = "a"
            }
            if releaseTouchAreaPath.contains(touchLocation) {
                currentDragArea = "r"
            }
            lastPoint = touchLocation
        }
        setNeedsDisplay()
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            
            if currentDragArea != "" {
                if currentDragArea == "ds" {
                    sustainPercent -= (touchLocation.y - lastPoint.y) / 10.0
                    decayTime += touchLocation.x - lastPoint.x
                }
                if currentDragArea == "a" {
                    attackTime += touchLocation.x - lastPoint.x
                    attackTime -= touchLocation.y - lastPoint.y
                }
                if currentDragArea == "r" {
                    releaseTime += touchLocation.x - lastPoint.x
                    releaseTime -= touchLocation.y - lastPoint.y
                }
            }
            if attackTime < 0 { attackTime = 0 }
            if decayTime < 0 { decayTime = 0 }
            if releaseTime < 0 { releaseTime = 0 }
            if sustainPercent < 0 { sustainPercent = 0 }
            if sustainPercent > 100 { sustainPercent = 100 }
            
            if let realCallback = self.callback {
                realCallback(Double(attackTime / 1000.0),
                             Double(decayTime / 1000.0),
                             Double(sustainPercent / 100.0),
                             Double(releaseTime / 1000.0))
            }
            lastPoint = touchLocation
        }
        setNeedsDisplay()
    }
    
    // MARK: - Drawing

    func drawCurveCanvas(size: CGSize = CGSize(width: 440, height: 151), attackDurationMS: CGFloat = 449, decayDurationMS: CGFloat = 262, releaseDurationMS: CGFloat = 448, sustainLevel: CGFloat = 0.583, maxADFraction: CGFloat = 0.75) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Variable Declarations
        let attackClickRoom = CGFloat(30) // to allow the attack to be clicked even if is zero
        let oneSecond: CGFloat = 0.65 * size.width
        let initialPoint = CGPoint(x: attackClickRoom, y: size.height)
        let buffer = CGFloat(10)//curveStrokeWidth / 2.0 // make a little room for drwing the stroke
        let endAxes = CGPoint(x: size.width, y: size.height)
        let releasePoint = CGPoint(x: attackClickRoom + oneSecond, y: sustainLevel * (size.height - buffer) + buffer)
        let endPoint = CGPoint(x: releasePoint.x + releaseDurationMS / 1000.0 * oneSecond, y: size.height)
        let endMax = CGPoint(x: min(endPoint.x, size.width), y: buffer)
        let releaseAxis = CGPoint(x: releasePoint.x, y: endPoint.y)
        let releaseMax = CGPoint(x: releasePoint.x, y: buffer)
        let highPoint  = CGPoint(x: attackClickRoom + min(oneSecond * maxADFraction, attackDurationMS / 1000.0 * oneSecond), y: buffer)
        let highPointAxis = CGPoint(x: highPoint.x, y: size.height)
        let highMax = CGPoint(x: highPoint.x, y: buffer)
        let minthing = min(oneSecond * maxADFraction, (attackDurationMS + decayDurationMS) / 1000.0 * oneSecond)
        let sustainPoint = CGPoint(x: max(highPoint.x, attackClickRoom + minthing),
                                   y: sustainLevel * (size.height - buffer) + buffer)
        let sustainAxis = CGPoint(x: sustainPoint.x, y: size.height)
        let initialMax = CGPoint(x: 0, y: buffer)

        let initialToHighControlPoint = CGPoint(x: initialPoint.x, y: highPoint.y)
        let highToSustainControlPoint = CGPoint(x: highPoint.x, y: sustainPoint.y)
        let releaseToEndControlPoint  = CGPoint(x: releasePoint.x, y: endPoint.y)

        //// attackTouchArea Drawing
        context!.saveGState()

        attackTouchAreaPath = UIBezierPath()
        attackTouchAreaPath.move(to: CGPoint(x: 0, y: size.height))
        attackTouchAreaPath.addLine(to: highPointAxis)
        attackTouchAreaPath.addLine(to: highMax)
        attackTouchAreaPath.addLine(to: initialMax)
        attackTouchAreaPath.addLine(to: CGPoint(x: 0, y: size.height))
        attackTouchAreaPath.close()
        bgColor.setFill()
        attackTouchAreaPath.fill()

        context!.restoreGState()

        //// decaySustainTouchArea Drawing
        context!.saveGState()

        decaySustainTouchAreaPath = UIBezierPath()
        decaySustainTouchAreaPath.move(to: highPointAxis)
        decaySustainTouchAreaPath.addLine(to: releaseAxis)
        decaySustainTouchAreaPath.addLine(to: releaseMax)
        decaySustainTouchAreaPath.addLine(to: highMax)
        decaySustainTouchAreaPath.addLine(to: highPointAxis)
        decaySustainTouchAreaPath.close()
        bgColor.setFill()
        decaySustainTouchAreaPath.fill()

        context!.restoreGState()


        //// releaseTouchArea Drawing
        context!.saveGState()

        releaseTouchAreaPath = UIBezierPath()
        releaseTouchAreaPath.move(to: releaseAxis)
        releaseTouchAreaPath.addLine(to: endAxes)
        releaseTouchAreaPath.addLine(to: endMax)
        releaseTouchAreaPath.addLine(to: releaseMax)
        releaseTouchAreaPath.addLine(to: releaseAxis)
        releaseTouchAreaPath.close()
        bgColor.setFill()
        releaseTouchAreaPath.fill()

        context!.restoreGState()


        //// releaseArea Drawing
        context!.saveGState()

        let releaseAreaPath = UIBezierPath()
        releaseAreaPath.move(to: releaseAxis)
        releaseAreaPath.addCurve(to: endPoint,
                                        controlPoint1: releaseAxis,
                                        controlPoint2: endPoint)
        releaseAreaPath.addCurve(to: releasePoint,
                                        controlPoint1: releaseToEndControlPoint,
                                        controlPoint2: releasePoint)
        releaseAreaPath.addLine(to: releaseAxis)
        releaseAreaPath.close()
        releaseColor.setFill()
        releaseAreaPath.fill()

        context!.restoreGState()


        //// sustainArea Drawing
        context!.saveGState()

        let sustainAreaPath = UIBezierPath()
        sustainAreaPath.move(to: sustainAxis)
        sustainAreaPath.addLine(to: releaseAxis)
        sustainAreaPath.addLine(to: releasePoint)
        sustainAreaPath.addLine(to: sustainPoint)
        sustainAreaPath.addLine(to: sustainAxis)
        sustainAreaPath.close()
        sustainColor.setFill()
        sustainAreaPath.fill()

        context!.restoreGState()


        //// decayArea Drawing
        context!.saveGState()

        let decayAreaPath = UIBezierPath()
        decayAreaPath.move(to: highPointAxis)
        decayAreaPath.addLine(to: sustainAxis)
        decayAreaPath.addCurve(to: sustainPoint,
                                      controlPoint1: sustainAxis,
                                      controlPoint2: sustainPoint)
        decayAreaPath.addCurve(to: highPoint,
                                      controlPoint1: highToSustainControlPoint,
                                      controlPoint2: highPoint)
        decayAreaPath.addLine(to: highPoint)
        decayAreaPath.close()
        decayColor.setFill()
        decayAreaPath.fill()

        context!.restoreGState()


        //// attackArea Drawing
        context!.saveGState()

        let attackAreaPath = UIBezierPath()
        attackAreaPath.move(to: initialPoint)
        attackAreaPath.addLine(to: highPointAxis)
        attackAreaPath.addLine(to: highPoint)
        attackAreaPath.addCurve(to: initialPoint,
                                       controlPoint1: initialToHighControlPoint,
                                       controlPoint2: initialPoint)
        attackAreaPath.close()
        attackColor.setFill()
        attackAreaPath.fill()

        context!.restoreGState()

        //// Curve Drawing
        context!.saveGState()

        let curvePath = UIBezierPath()
        curvePath.move(to: initialPoint)
        curvePath.addCurve(to: highPoint,
                                  controlPoint1: initialPoint,
                                  controlPoint2: initialToHighControlPoint)
        curvePath.addCurve(to: sustainPoint,
                                  controlPoint1: highPoint,
                                  controlPoint2: highToSustainControlPoint)
        curvePath.addLine(to: releasePoint)
        curvePath.addCurve(to: endPoint,
                                  controlPoint1: releasePoint,
                                  controlPoint2: releaseToEndControlPoint)
        curveColor.setStroke()
        curvePath.lineWidth = curveStrokeWidth
        curvePath.stroke()

        context!.restoreGState()
    }



    override open func draw(_ rect: CGRect) {
        drawCurveCanvas(size: rect.size, attackDurationMS: attackTime,
                        decayDurationMS: decayTime,
                        releaseDurationMS: releaseTime,
                        sustainLevel: 1.0 - sustainPercent / 100.0)
    }
}

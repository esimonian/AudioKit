//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

var stopOuterPath = UIBezierPath()
var playOuterPath = UIBezierPath()
var upOuterPath = UIBezierPath()
var downOuterPath = UIBezierPath()

let context = UIGraphicsGetCurrentContext()

//// Color Declarations
let sliderColor = UIColor(red: 1.000, green: 0.000, blue: 0.062, alpha: 1.000)
let backgroundColor = UIColor(red: 0.835, green: 0.842, blue: 0.836, alpha: 0.925)
let color = UIColor(red: 0.029, green: 1.000, blue: 0.000, alpha: 1.000)
let dark = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

let container = UIView(frame: CGRect(x: 0, y: 0, width: 440, height: 60))
container.backgroundColor = backgroundColor

//// background Drawing
let backgroundPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 440, height: 60))
backgroundColor.setFill()
backgroundPath.fill()

let path = UIBezierPath()
path.moveToPoint(CGPointMake(50, 100))
path.addLineToPoint(CGPointMake(150, 100))
UIColor.orangeColor().setStroke()
path.stroke()
container.su

XCPlaygroundPage.currentPage.liveView = container











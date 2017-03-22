//
//  HelmoFaceView.swift
//  Helmo
//
//  Created by Mihnea Rusu on 06/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import UIKit

class HelmoFaceView: UIView {
    /**
        At scale 1x1, the dimensions are as follows:
            w: 184.15
            h: 199.80
    */
    
    let defaultW: CGFloat = 184.15
    let defaultH: CGFloat = 199.80
    
    var w: CGFloat = 184.15
    var h: CGFloat = 199.80
    
    var tX: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var tY: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var scaleX: CGFloat = 1 {
        didSet {
            w = defaultW * scaleX
            setNeedsDisplay()
        }
    }
    var scaleY: CGFloat = 1 {
        didSet {
            h = defaultH * scaleY
            setNeedsDisplay()
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.926, green: 0.112, blue: 0.141, alpha: 1.000)
        let fillColor2 = UIColor(red: 0.928, green: 0.140, blue: 0.152, alpha: 1.000)
        let fillColor3 = UIColor(red: 0.137, green: 0.122, blue: 0.125, alpha: 1.000)
        let fillColor4 = UIColor(red: 0.996, green: 0.996, blue: 0.995, alpha: 1.000)
        let fillColor5 = UIColor(red: 0.981, green: 0.687, blue: 0.249, alpha: 1.000)
        
        //// helmo-face-logo Group
        context.saveGState()
        context.translateBy(x: tX, y: tY)
        context.scaleBy(x: scaleX, y: scaleY)
        
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 26.73, y: 42.3, width: 130.7, height: 134.5))
        fillColor.setFill()
        ovalPath.fill()
        
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 135.98, y: 65.18))
        bezierPath.addCurve(to: CGPoint(x: 92.08, y: 46.77), controlPoint1: CGPoint(x: 124.06, y: 52.91), controlPoint2: CGPoint(x: 109.42, y: 46.77))
        bezierPath.addCurve(to: CGPoint(x: 48.16, y: 65.18), controlPoint1: CGPoint(x: 74.72, y: 46.77), controlPoint2: CGPoint(x: 60.09, y: 52.91))
        bezierPath.addCurve(to: CGPoint(x: 30.27, y: 109.85), controlPoint1: CGPoint(x: 36.24, y: 77.46), controlPoint2: CGPoint(x: 30.27, y: 92.35))
        bezierPath.addCurve(to: CGPoint(x: 48.16, y: 154.52), controlPoint1: CGPoint(x: 30.27, y: 127.35), controlPoint2: CGPoint(x: 36.24, y: 142.24))
        bezierPath.addCurve(to: CGPoint(x: 92.08, y: 172.93), controlPoint1: CGPoint(x: 60.09, y: 166.79), controlPoint2: CGPoint(x: 74.72, y: 172.93))
        bezierPath.addCurve(to: CGPoint(x: 135.98, y: 154.52), controlPoint1: CGPoint(x: 109.42, y: 172.93), controlPoint2: CGPoint(x: 124.06, y: 166.79))
        bezierPath.addCurve(to: CGPoint(x: 153.88, y: 109.85), controlPoint1: CGPoint(x: 147.91, y: 142.24), controlPoint2: CGPoint(x: 153.88, y: 127.35))
        bezierPath.addCurve(to: CGPoint(x: 135.98, y: 65.18), controlPoint1: CGPoint(x: 153.88, y: 92.35), controlPoint2: CGPoint(x: 147.91, y: 77.46))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 157.63, y: 174.05))
        bezierPath.addCurve(to: CGPoint(x: 92.08, y: 199.8), controlPoint1: CGPoint(x: 139.95, y: 191.22), controlPoint2: CGPoint(x: 118.1, y: 199.8))
        bezierPath.addCurve(to: CGPoint(x: 26.52, y: 174.05), controlPoint1: CGPoint(x: 66.05, y: 199.8), controlPoint2: CGPoint(x: 44.2, y: 191.22))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 109.85), controlPoint1: CGPoint(x: 8.84, y: 156.88), controlPoint2: CGPoint(x: 0, y: 135.48))
        bezierPath.addCurve(to: CGPoint(x: 26.52, y: 45.65), controlPoint1: CGPoint(x: 0, y: 84.22), controlPoint2: CGPoint(x: 8.84, y: 62.82))
        bezierPath.addCurve(to: CGPoint(x: 92.08, y: 19.89), controlPoint1: CGPoint(x: 44.2, y: 28.48), controlPoint2: CGPoint(x: 66.05, y: 19.89))
        bezierPath.addCurve(to: CGPoint(x: 157.63, y: 45.65), controlPoint1: CGPoint(x: 118.1, y: 19.89), controlPoint2: CGPoint(x: 139.95, y: 28.48))
        bezierPath.addCurve(to: CGPoint(x: 184.15, y: 109.85), controlPoint1: CGPoint(x: 175.31, y: 62.82), controlPoint2: CGPoint(x: 184.15, y: 84.22))
        bezierPath.addCurve(to: CGPoint(x: 157.63, y: 174.05), controlPoint1: CGPoint(x: 184.15, y: 135.48), controlPoint2: CGPoint(x: 175.31, y: 156.88))
        bezierPath.close()
        fillColor2.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 92.07, y: 175.41))
        bezier2Path.addCurve(to: CGPoint(x: 61.03, y: 166.39), controlPoint1: CGPoint(x: 80.97, y: 175.08), controlPoint2: CGPoint(x: 70.47, y: 172.88))
        bezier2Path.addCurve(to: CGPoint(x: 41.24, y: 141.83), controlPoint1: CGPoint(x: 51.59, y: 159.89), controlPoint2: CGPoint(x: 43.06, y: 145.44))
        bezier2Path.addCurve(to: CGPoint(x: 26.9, y: 113.89), controlPoint1: CGPoint(x: 39.43, y: 138.22), controlPoint2: CGPoint(x: 32.89, y: 120.21))
        bezier2Path.addCurve(to: CGPoint(x: 92.07, y: 126.21), controlPoint1: CGPoint(x: 26.9, y: 113.89), controlPoint2: CGPoint(x: 62.39, y: 126.21))
        bezier2Path.addCurve(to: CGPoint(x: 157.25, y: 113.81), controlPoint1: CGPoint(x: 121.76, y: 126.21), controlPoint2: CGPoint(x: 157.25, y: 113.81))
        bezier2Path.addCurve(to: CGPoint(x: 142.9, y: 141.83), controlPoint1: CGPoint(x: 151.25, y: 120.12), controlPoint2: CGPoint(x: 144.72, y: 138.22))
        bezier2Path.addCurve(to: CGPoint(x: 123.12, y: 166.39), controlPoint1: CGPoint(x: 141.09, y: 145.44), controlPoint2: CGPoint(x: 132.56, y: 159.89))
        bezier2Path.addCurve(to: CGPoint(x: 92.07, y: 175.41), controlPoint1: CGPoint(x: 113.67, y: 172.88), controlPoint2: CGPoint(x: 103.18, y: 175.74))
        bezier2Path.close()
        fillColor3.setFill()
        bezier2Path.fill()
        
        
        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalIn: CGRect(x: 26.88, y: 0, width: 69.8, height: 68.7))
        fillColor4.setFill()
        oval2Path.fill()
        
        
        //// Oval 3 Drawing
        let oval3Path = UIBezierPath(ovalIn: CGRect(x: 53.73, y: 24.1, width: 27.3, height: 26.3))
        fillColor3.setFill()
        oval3Path.fill()
        
        
        //// Oval 4 Drawing
        let oval4Path = UIBezierPath(ovalIn: CGRect(x: 87.38, y: 0.05, width: 69.7, height: 68.6))
        fillColor4.setFill()
        oval4Path.fill()
        
        
        //// Oval 5 Drawing
        let oval5Path = UIBezierPath(ovalIn: CGRect(x: 103.03, y: 24.1, width: 27.3, height: 26.3))
        fillColor3.setFill()
        oval5Path.fill()
        
        
        //// Oval 6 Drawing
        let oval6Path = UIBezierPath(ovalIn: CGRect(x: 62.88, y: 48.45, width: 58.4, height: 66.5))
        fillColor5.setFill()
        oval6Path.fill()
        
        context.restoreGState()
    }
}


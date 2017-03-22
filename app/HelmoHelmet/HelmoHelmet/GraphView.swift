//
//  GraphView.swift
//  CoreMotionTest
//
//  Created by Mihnea Rusu on 31/01/16.
//  Copyright © 2016 Mihnea Rusu. All rights reserved.
//

import UIKit
import CoreMotion

protocol GraphViewDataSource: class {
    func dataToGraph(_ sender: GraphView) -> MotionDataContainer?
}

enum DisplayState {
    case disconnected, connecting, connected
}

class GraphView: UIView {
    
    @IBInspectable
    var lineWidth : CGFloat = 2 { didSet { setNeedsDisplay() } }
    
    var connectionIndicator: DisplayState = .disconnected
    var graphCenter : CGPoint {
        return convert(center, from: superview)
    }
    
    var graphWidth : CGFloat {
        return bounds.size.width
    }
    
    var graphHeight : CGFloat {
        return bounds.size.height
    }
    
    var scaleY = CGFloat()
    var offsetY = CGFloat()
    var scaleData : CGFloat = 1.0
    
    enum MaxValueConstants {
        static let acceleration : Double = 3.0
        static let velocity : Double = 0.5
        static let displacement : Double = 0.5
    }
    
    enum IndicatorConstants {
        static let radius : CGFloat = 10.0
        static let offsetX : CGFloat = 10.0
        static let offsetY : CGFloat = 10.0
    }
    
    
    fileprivate func plotPoints(_ data: [Double]) -> UIBezierPath {
        var dataPoints = [CGPoint]()
        
        var tempPoint = CGPoint()
        
        let path = UIBezierPath()
        var maxVal = Double()
        

        maxVal = MaxValueConstants.acceleration
        scaleY = graphHeight/2
        offsetY = graphHeight/2

        
        for (memberCounter,dataMember) in data.enumerated() {
            if (data.count > 0) {
                tempPoint.x = CGFloat(memberCounter)/CGFloat(data.count)*graphWidth
            }
            tempPoint.y = offsetY - min(scaleData*CGFloat(dataMember/maxVal),1)*scaleY
            dataPoints.append(tempPoint)
            
            if(memberCounter == 0) {
                path.move(to: tempPoint)
            } else {
                path.addLine(to: tempPoint)
            }
            
        }
        
        path.lineWidth = lineWidth
        return path
    }
    
    func scaleGraph(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scaleData *= CGFloat(gesture.scale)
            //print("scaleData: \(scaleData)")
            gesture.scale = 1
        }
    }
    
    fileprivate func drawIndicator(_ currentDisplayState: DisplayState) -> UIBezierPath {
        // We're using these colours: http://www.colourlovers.com/palette/4063881/Beachhouse
        // Update: Actually we're not, just using the x - + colours on OS X windows
        
        let center = CGPoint(x: IndicatorConstants.radius + IndicatorConstants.offsetX, y: IndicatorConstants.radius + IndicatorConstants.offsetY)
        let path = UIBezierPath(arcCenter: center, radius: IndicatorConstants.radius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        
        
        switch currentDisplayState {
        case .disconnected:
            let red = UIColor(red: 0.926, green: 0.112, blue: 0.141, alpha: 1.000)
            red.setFill()
            path.fill()
        case .connecting:
            let yellow = UIColor(red: 0.981, green: 0.687, blue: 0.249, alpha: 1.000)
            yellow.setFill()
            path.fill()
        case .connected:
            let green = UIColor(red: 0.1608, green: 0.8039, blue: 0.2588, alpha: 1.0)
            green.setFill()
            path.fill()
        }
        
        return path
    }
    
    weak var dataSource : GraphViewDataSource?
    
    override func draw(_ rect: CGRect) {
        let _ = drawIndicator(connectionIndicator)
        
        let data = dataSource?.dataToGraph(self) ?? MotionDataContainer(x: [Double](repeating: 0.0, count: 2), y: [Double](repeating: 0.0, count: 2), z: [Double](repeating: 0.0, count: 2), timestamp: [0.0])
        
        UIColor.red.setStroke()
        plotPoints(data.x).stroke()
        UIColor.green.setStroke()
        plotPoints(data.y).stroke()
        UIColor.blue.setStroke()
        plotPoints(data.z).stroke()
    }
}


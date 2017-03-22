//
//  CoreMotionTestModel.swift
//  CoreMotionTest
//
//  Created by Mihnea Rusu on 21/01/16.
//  Copyright © 2016 Mihnea Rusu. All rights reserved.
//


import Foundation
import CoreMotion
import Accelerate

struct MotionDataContainer {
    var x : [Double]
    var y : [Double]
    var z : [Double]
    var timestamp : [Double]
    
    init(x: [Double], y: [Double], z: [Double], timestamp: [Double]) {
        self.x = x
        self.y = y
        self.z = z
        self.timestamp = timestamp
    }
    
    init() {
        x = [Double]()
        y = [Double]()
        z = [Double]()
        timestamp = [Double]()
    }
}

protocol CoreMotionTestModelDelegate: class {
    func fallDetected(_ sender: CoreMotionTestModel, state: Bool)
    func updatedDeviceMotion(_ sender: CoreMotionTestModel, deviceMotionData: CMDeviceMotion)
}

class CoreMotionTestModel: NSObject {
    // aX, maxMag, minMag, peak, num elements
    let weights: [Double] = [-2.0, 6.58, 40e-3, -2.62, 81.0]
    let thresholdNumElements = 0.66
    
    var motionManager: CMMotionManager! = nil
    
    var xAccMax: Double = 0.0
    var yAccMax: Double = 0.0
    var zAccMax: Double = 0.0
    var accMagMax: Double = 0.0
    var accMagMin: Double = 0.0
    
    var accContainer = MotionDataContainer()
    var accMag = [Double]()
    let fallThreshold = 1.6 // gravity

    var totalNumSamples = 0
    var applyIIRFilter = false
    
    var sampleCount: Int = 0
    var numSamples: Int = 100
    
    var processingCounter: Int = 0
    var processingThreshold: Int {
        get {
            return numSamples/2
        }
    }
    
    weak var delegate: CoreMotionTestModelDelegate?
    
    override init() {
        super.init()
        
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1/60 // 60 fps
    }
    
    func startUpdates(uiUpdateHandler: @escaping () -> Void) {
        let queue = OperationQueue()
        // let referenceFrame : CMAttitudeReferenceFrame = .XArbitraryCorrectedZVertical
        
        motionManager.startDeviceMotionUpdates(to: queue) {
            (deviceMotionData: CMDeviceMotion?, error: Error?) -> Void in
            
            guard deviceMotionData != nil else {
                return
            }
            
            self.processingCounter = self.processingCounter + 1
            
            self.updateAcceleration(deviceMotionData!.userAcceleration, timestamp: deviceMotionData!.timestamp)
            
            self.delegate?.updatedDeviceMotion(self, deviceMotionData: deviceMotionData!)
            
            if self.processingCounter == self.processingThreshold {
                self.processMagnitudes()
                self.processingCounter = 0
            }
            
            
            DispatchQueue.main.async {
                uiUpdateHandler()
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    fileprivate func processMagnitudes() {
//        // find max
//        if let max = accMag.max() {
//            if max > fallThreshold {
//                print("Fall detected!")
//                delegate?.fallDetected(self, state: true)
//            }
//        }
        
        // find min
        let numEl = numElementsBelowThreshold(array: accMag, threshold: thresholdNumElements)
        let peakToPeak = accMagMax - accMagMin
        
        let a0 = accContainer.x.last ?? 0.0 * weights[0]
        let a1 = accMagMax * weights[1]
        let a2 = accMagMin * weights[2]
        let a3 = peakToPeak * weights[3]
        let a4 = numEl * weights[4]
        
        let sum = a0 + a1 + a2 + a3 + a4
        if (sum > 0) {
            print("Fall detected!")
            delegate?.fallDetected(self, state: true)
        }
        
        // find mean
    }
    
    fileprivate func updateAcceleration(_ accelerationData: CMAcceleration, timestamp: TimeInterval) {
        
        let mag = sqrt(pow(accelerationData.x, 2) + pow(accelerationData.y, 2) + pow(accelerationData.z, 2))
        
        if(sampleCount < numSamples) {
            accContainer.x.append(accelerationData.x)
            accContainer.y.append(accelerationData.y)
            accContainer.z.append(accelerationData.z)
            accContainer.timestamp.append(timestamp)
        
            accMag.append(mag)
            
            sampleCount = sampleCount + 1
        } else {
            // Shift the arrays up in place
            if !accContainer.x.isEmpty {
                accContainer.x.removeFirst()
            }
            accContainer.x.append(accelerationData.x)
        
            if !accContainer.y.isEmpty {
                accContainer.y.removeFirst()
            }
            accContainer.y.append(accelerationData.y)
            
            if !accContainer.z.isEmpty {
                accContainer.z.removeFirst()
            }
            accContainer.z.append(accelerationData.z)
            
            if !accContainer.timestamp.isEmpty {
                accContainer.timestamp.removeFirst()
            }
            accContainer.timestamp.append(timestamp)
            
            if !accMag.isEmpty {
                accMag.removeFirst()
            }
            accMag.append(mag)
        }
        
        // Check to see if we've reached a new maximum, update max labels
        xAccMax = accContainer.x.max() ?? 0.0
        yAccMax = accContainer.y.max() ?? 0.0
        zAccMax = accContainer.z.max() ?? 0.0
        accMagMax = accMag.max() ?? 0.0
        accMagMin = accMag.min() ?? 0.0
        
    }
}

private func numElementsBelowThreshold(array: [Double], threshold: Double) -> Int {
    var count = 0
    
    for i in 0..<array.count {
        if array[i] < threshold {
            count = count + 1
        }
    }
    
    return count
}

extension CoreMotionTestModel: GraphViewDataSource {
    func dataToGraph(_ sender: GraphView) -> MotionDataContainer? {
        return accContainer
    }
}


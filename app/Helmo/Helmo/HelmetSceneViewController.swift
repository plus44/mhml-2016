//
//  MySceneViewController.swift
//  Helmo
//
//  Created by Mihnea Rusu on 03/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import UIKit
import simd
import CoreMotion

protocol HelmetSceneViewControllerDataSource: class {
    func updateAttitude(_ sender: HelmetSceneViewController) -> MetalAttitude
}

class HelmetSceneViewController: MetalViewController {
    
    var motionManager: CMMotionManager! = nil
    var deviceMotionData: CMDeviceMotion? = nil
    
    var worldModelMatrix: float4x4!
    var objectToDraw: Model!
    
    let panSensitivity: Float = 3
    var lastPanLocation: CGPoint!
    
    weak var dataSource: HelmetSceneViewControllerDataSource? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queue = OperationQueue()
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1/60 // 60 fps
        motionManager.startDeviceMotionUpdates(to: queue) {
            (deviceMotionData: CMDeviceMotion?, error: Error?) -> Void in
            
            guard deviceMotionData != nil else {
                return
            }
            
            self.deviceMotionData = deviceMotionData
            
        }
        
        worldModelMatrix = float4x4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -0.1)
        worldModelMatrix.rotateAroundX(float4x4.degrees(toRad: 25.0), y: 0.0, z: 0.0)
        
//        objectToDraw = Model(name: "farmhouse", modelPath: "Data/Assets/farmhouse/farmhouse.obj", texturePath: "Data/Assets/farmhouse/farmhouse.png", device: device, vertexDescriptor: mdlVertexDescriptor, mtkBufferAllocator: mtkBufferAllocator, textureLoader: textureLoader)
        objectToDraw = Model(name: "helmet", modelPath: "Data/Assets/helmet/casque.obj", texturePath: "Data/Assets/helmet/carbon-fibre.png", device: device, vertexDescriptor: mdlVertexDescriptor, mtkBufferAllocator: mtkBufferAllocator, textureLoader: textureLoader)
        
        objectToDraw.posX = objectToDraw.posX - 0.05
        objectToDraw.posY = objectToDraw.posY - 0.025
        
//        objectToDraw = Cube(device: device, commandQueue: commandQueue, textureLoader: textureLoader)
        setupGestures()
        
        self.metalViewControllerDelegate = self
    }
    
    // MARK: Gesture related
    func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(HelmetSceneViewController.pan))
        self.view.addGestureRecognizer(pan)
    }
    
    func pan(panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .changed {
            let pointInView = panGesture.location(in: self.view)
            
            let xDelta = Float((lastPanLocation.x - pointInView.x) / self.view.bounds.width)
            let yDelta = Float((lastPanLocation.y - pointInView.y) / self.view.bounds.height)
            
            var xAdj: Float = 0.0
            var yAdj: Float = 0.0
        
            if abs(xDelta) > abs(yDelta) {
                yAdj = -yDelta/abs(xDelta)
                xAdj = -xDelta/abs(xDelta)
            } else if abs(yDelta) > abs(xDelta) {
                xAdj = -xDelta/abs(yDelta)
                yAdj = -yDelta/abs(yDelta)
            }
            // print("xAdj: \(xAdj), yAdj: \(yAdj)")

            worldModelMatrix.rotateAroundX(yAdj * float4x4.degrees(toRad: panSensitivity), y: xAdj * float4x4.degrees(toRad: panSensitivity), z: 0.0)
            
            // worldModelMatrix.rotate(float4x4.degrees(toRad: panSensitivity), x: xAdj, y: yAdj, z: 0.0)
            
            // objectToDraw.rotY = objectToDraw.rotY - xDelta
            // objectToDraw.rotX = objectToDraw.rotX - yDelta
            lastPanLocation = pointInView
        } else if panGesture.state == .began {
            lastPanLocation = panGesture.location(in: self.view)
        }
    }
}

// MARK: MetalViewControllerDelegate
extension HelmetSceneViewController: MetalViewControllerDelegate {
    func renderObjects(drawable: CAMetalDrawable) {
//        if let dataSource = self.dataSource {
//            let attitude = dataSource.updateAttitude(self)
//            
//            self.objectToDraw.rotX = Float(attitude.pitch)
//            self.objectToDraw.rotY = Float(attitude.yaw)
//            self.objectToDraw.rotZ = Float(attitude.roll)
//        }
        
        if let deviceMotionData = self.deviceMotionData {
            self.objectToDraw.rotX = Float(deviceMotionData.attitude.pitch)
            self.objectToDraw.rotY = Float(deviceMotionData.attitude.yaw)
            self.objectToDraw.rotZ = Float(deviceMotionData.attitude.roll)
        }
        
        self.objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, depthStencilState: depthStencilState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    }
    
    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
        // objectToDraw.updateWith(delta: timeSinceLastUpdate)
    }
}

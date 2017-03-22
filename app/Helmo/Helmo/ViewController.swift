//
//  ViewController.swift
//  Helmo
//
//  Created by Mihnea Rusu on 01/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {

    var objectToDraw: Cube!
    var projectionMatrix: Matrix4!
    
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil

    // Keeps track of the compiled render pipeline
    var pipelineState: MTLRenderPipelineState! = nil
    // Command queue that tells the GPU what to do
    var commandQueue: MTLCommandQueue! = nil
    // Store the depths of the objects
    var depthStencilState: MTLDepthStencilState! = nil
    
    // Timer that triggers every frame refresh
    var timer: CADisplayLink! = nil
    var lastFrameTimestamp: CFTimeInterval = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*** ONE TIME INITIALIZATION CODE ***/
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
        
        // Initialize the device and the CAMetalLayer
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer() // Create a new layer to display the render
        metalLayer.device = device // Use the MTLDevice we created
        metalLayer.pixelFormat = .bgra8Unorm // Use RGBA 8 bytes each, values 0->1
        metalLayer.framebufferOnly = true // Apple encourages this setting as true
        metalLayer.frame = view.layer.frame // The frame of the layer matches the frame of the view
        view.layer.addSublayer(metalLayer) // Add a sublayer to the view's main layer
        
        // Initialize the GPU buffer of vertices
        objectToDraw = Cube(device: device)
        
        // Fetch the precompiled shaders from the library
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary!.makeFunction(name: "basic_vertex")
        
        // Set up the render pipeline state
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let pipelineError as NSError {
            print("Failed to create pipeline state, error \(pipelineError)")
        }
        
        // Initialise the command queue
        commandQueue = device.makeCommandQueue()
        
        // Initialise the depth stencil state
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        
        
        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        /*** ONE TIME INITIALIZATION CODE END ***/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func render() {
        let drawable = metalLayer.nextDrawable()
        if let drawable = drawable {
            let worldModelMatrix = Matrix4()!
            worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
            worldModelMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: Matrix4.degrees(toRad: 30), z: 0.0)
            
            objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, depthStencilState: depthStencilState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: MTLClearColorMake(172.0/255.0, 211.0/255.0, 221.0/255.0, 1.0))
        }
    }

    /**
        Called to update and render the model again
    */
    func gameLoop(timeSinceLastUpdate: CFTimeInterval) {
        
        objectToDraw.updateWith(delta: timeSinceLastUpdate)
        
        autoreleasepool {
            self.render()
        }
    }
    
    /**
        Called by the display refresh timer at (hopefully) 60 FPS
    */
    func newFrame(displayLink: CADisplayLink) {
        
        // Is it the first we're getting the timestamp?
        if lastFrameTimestamp == 0.0 {
            lastFrameTimestamp = displayLink.timestamp
        }
        
        // Find the time elapsed between this frame and the previous frame
        let elapsed: CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp
        
        gameLoop(timeSinceLastUpdate: elapsed)
    }
}


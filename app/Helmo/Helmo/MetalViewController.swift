//
//  MetalViewController.swift
//  Helmo
//
//  Created by Mihnea Rusu on 03/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import UIKit
import MetalKit
import QuartzCore
import simd

protocol MetalViewControllerDelegate: class {
    func updateLogic(timeSinceLastUpdate: CFTimeInterval)
    func renderObjects(drawable: CAMetalDrawable)
}

class MetalViewController: UIViewController {
    
    var device: MTLDevice! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var depthStencilState: MTLDepthStencilState! = nil
    var textureLoader: MTKTextureLoader! = nil
    var mdlVertexDescriptor: MDLVertexDescriptor! = nil
    var mtkBufferAllocator: MTKMeshBufferAllocator! = nil
    
    var projectionMatrix: float4x4!
    
    weak var metalViewControllerDelegate: MetalViewControllerDelegate?
    
    @IBOutlet weak var mtkView: MTKView! {
        didSet {
            mtkView.delegate = self
            mtkView.preferredFramesPerSecond = 60
            mtkView.clearColor = MTLClearColorMake(113.0/255.0, 198.0/255.0, 240.0/255.0, 1.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
        
        device = MTLCreateSystemDefaultDevice()
        textureLoader = MTKTextureLoader(device: device)
        mtkView.device = device
        
        mtkBufferAllocator = MTKMeshBufferAllocator(device: device)
        
        commandQueue = device.makeCommandQueue()
        
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary!.makeFunction(name: "basic_vertex")
        
        // Initialise the vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = .float3 // Position
        vertexDescriptor.attributes[1].offset = 12
        vertexDescriptor.attributes[1].format = .float4 // Color
        vertexDescriptor.attributes[2].offset = 28
        vertexDescriptor.attributes[2].format = .float2 // Tex coord
        vertexDescriptor.attributes[3].offset = 36
        vertexDescriptor.attributes[3].format = .float3 // Normal
        vertexDescriptor.layouts[0].stride = 48
        
        // Initialise the Model IO vertex descriptor
        mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        (mdlVertexDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (mdlVertexDescriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeColor
        (mdlVertexDescriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
        (mdlVertexDescriptor.attributes[3] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        
        // Initialise the pipeline state descriptor
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error as NSError {
            print("Failed initializing Metal pipeline \(error)")
        }
        
        // Initialise the depth stencil state
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
    
    
    func render(_ drawable: CAMetalDrawable?) {
        guard let drawable = drawable else {
            return
        }
        
        self.metalViewControllerDelegate?.renderObjects(drawable: drawable)
    }
}

extension MetalViewController: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
    }
    
    func draw(in view: MTKView) {
        render(view.currentDrawable)
    }
}

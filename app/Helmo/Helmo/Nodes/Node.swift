//
//  Node.swift
//  Helmo
//
//  Created by Mihnea Rusu on 03/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation
import Metal
import QuartzCore
import simd

class Node {
    
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    var bufferProvider: BufferProvider
    var device: MTLDevice
    
    var texture: MTLTexture
    lazy var samplerState: MTLSamplerState? = Node.defaultSampler(device: self.device)
    
    // Position coordinates in the world
    var posX: Float     = 0.0
    var posY: Float     = 0.0
    var posZ: Float     = 0.0
    
    var rotX: Float     = 0.0
    var rotY: Float     = 0.0
    var rotZ: Float     = 0.0
    var scale: Float    = 1.0
    let light = Light(color: (1.0, 1.0, 1.0), ambientIntensity: 0.1, direction: (0.0, 0.0, 1.0), diffuseIntensity: 0.8, shininess: 10.0, specularIntensity: 0.5)
    
    var time: CFTimeInterval = 0.0
    
    
    
    /**
        Initialize the Node with a name, an array of vertices and a Metal device
    */
    init(name: String, vertices: Array<Vertex>, device: MTLDevice, texture: MTLTexture) {
        // Form a buffer of floats that looks like: [x,y,z,r,g,b,a , x,y,z,r,g,b,a , ...]
        var vertexData = Array<Float>()
        for vertex in vertices {
            vertexData = vertexData + vertex.floatBuffer()
        }
        
        // Create a GPU buffer with the float buffer above
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        // Set the instance variables
        self.name = name
        self.device = device
        self.vertexCount = vertices.count
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3)
        self.texture = texture
    }
    
    /**
        Render the node on the Metal device
    */
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, depthStencilState: MTLDepthStencilState, drawable: CAMetalDrawable, parentModelViewMatrix: float4x4, projectionMatrix: float4x4, clearColor: MTLClearColor?) {
        
        // Check whether we need to stall the CPU thread or not
        let _ = self.bufferProvider.availableResourcesSemaphore.wait(timeout: .distantFuture)
        
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        if let clearColor = clearColor {
            renderPassDescriptor.colorAttachments[0].clearColor = clearColor
        } else {
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 104.0/255.0, 5.0/255.0, 1.0)
        }
        
        
        // Create a buffer of commands
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.addCompletedHandler { (commandBuffer) -> Void in
            self.bufferProvider.availableResourcesSemaphore.signal()
        }
        
        
        // Create an encoder in our command buffer and link it to the pipeline
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        // Fix the transparency issue for triangles drawn in CCW order
        // renderEncoder.setCullMode(.front)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
        // Pass the vertex buffer of the model we're rendering as parameter 0 to the GPU
        renderEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, at: 0)
        renderEncoder.setFragmentTexture(texture, at: 0)
        if let samplerState = samplerState {
            renderEncoder.setFragmentSamplerState(samplerState, at: 0)
        }
        // Create a model matrix for the current state of the model
        var nodeModelMatrix = self.modelMatrix()
        // Shift the model to the camera perspective (pre-multiply before passing to the GPU for efficiency)
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        // Fetch the next available buffer
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, modelViewMatrix: nodeModelMatrix, light: light)
        // Pass the uniforms buffer (containing the matrices transforming our model) as parameter 1 to the GPU in both the vertex and fragment shaders
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, at: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder.endEncoding()
        
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    /** 
        Return a float4x4 representation of the model
    */
    func modelMatrix() -> float4x4 {
        var matrix = float4x4()
        matrix.translate(posX, y: posY, z: posZ)
        matrix.rotateAroundX(rotX, y: rotY, z: rotZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
    
    func updateWith(delta: CFTimeInterval) {
        time = time + delta
    }
    
    /**
        Creates a default texture sampler on the provided MTLDevice
    */
    class func defaultSampler(device: MTLDevice) -> MTLSamplerState? {
        
        let pSamplerDescriptor: MTLSamplerDescriptor? = MTLSamplerDescriptor()
        if let sampler = pSamplerDescriptor {
            sampler.minFilter               = .nearest
            sampler.magFilter               = .nearest
            sampler.mipFilter               = .nearest
            sampler.maxAnisotropy           = 1
            sampler.sAddressMode            = .clampToEdge
            sampler.tAddressMode            = .clampToEdge
            sampler.rAddressMode            = .clampToEdge
            sampler.normalizedCoordinates   = true
            sampler.lodMinClamp             = 0
            sampler.lodMaxClamp             = FLT_MAX
            
            return device.makeSamplerState(descriptor: pSamplerDescriptor!)
        } else {
            print("Error: Failed creating a sampler descriptor")
            return nil
        }
    }
}

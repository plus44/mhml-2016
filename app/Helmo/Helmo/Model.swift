//
//  Model.swift
//  Helmo
//
//  Created by Mihnea Rusu on 06/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import QuartzCore
import simd

class Model {
    
    let name: String
    var device: MTLDevice
    var vertexDescriptor: MDLVertexDescriptor
    var bufferProvider: BufferProvider
    var asset: MDLAsset
    var texture: MTLTexture?
    var vertexBuffer: MTKMeshBuffer
    let submesh: MTKSubmesh
    lazy var samplerState: MTLSamplerState? = Model.defaultSampler(device: self.device)
    
    
    // Position coordinates in the world
    var posX: Float     = 0.0
    var posY: Float     = 0.0
    var posZ: Float     = 0.0
    
    var rotX: Float     = 0.0
    var rotY: Float     = 0.0
    var rotZ: Float     = 0.0
    var scale: Float    = 1.0
    let light = Light(color: (1.0, 1.0, 1.0), ambientIntensity: 0.1, direction: (0.0, 0.0, 1.0), diffuseIntensity: 0.8, shininess: 5.0, specularIntensity: 1)
    
    var time: CFTimeInterval = 0.0
    
    
    /**
        Initialize the model from a path containing the .obj file, with the MetalViewController's vertexDescriptor a buffer allocator and a texture (optionally).
    */
    init(name: String, modelPath: String, texturePath: String?, device: MTLDevice, vertexDescriptor: MDLVertexDescriptor, mtkBufferAllocator: MTKMeshBufferAllocator, textureLoader: MTKTextureLoader?) {
        
        let url = Bundle.main.url(forResource: modelPath, withExtension: nil)
        // Load the asset from file
        self.asset = MDLAsset(url: url!, vertexDescriptor: vertexDescriptor, bufferAllocator: mtkBufferAllocator)
        
        let mesh = asset.object(at: 0) as? MDLMesh
        print("Model '\(name)': Loaded mesh with \(mesh?.vertexCount) vertices")
//        mesh!.generateAmbientOcclusionVertexColors(withQuality: 1, attenuationFactor: 0.98, objectsToConsider: [mesh!], vertexAttributeNamed: MDLVertexAttributeOcclusionValue)

        let meshes = try! MTKMesh.newMeshes(from: asset, device: device, sourceMeshes: nil)
        print("Model '\(name)': Number of meshes: \(meshes.count)")
        let firstMesh = (meshes.first)!
        self.vertexBuffer = firstMesh.vertexBuffers[0]
        submesh = firstMesh.submeshes.first!
        print("Model '\(name)': Number of submeshes in firstMesh: \(firstMesh.submeshes.count)")
        
        self.name = name
        self.device = device
        self.vertexDescriptor = vertexDescriptor
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3)
        // Load the model texture
        if let textureLoader = textureLoader {
            let url = Bundle.main.url(forResource: texturePath, withExtension: nil)
            let data = try! Data(contentsOf: url!)
            do {
                self.texture = try textureLoader.newTexture(with: data, options: nil)
            } catch let error {
                print("Model '\(name)': Failed loading texture with error: \(error).")
            }
            
        }
    }
    
    
    /**
        Called every new frame, when the model requires rendering
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
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(113.0/255.0, 198.0/255.0, 240.0/255.0, 1.0)
        }
        
        // Create a buffer of commands on the command queue
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.addCompletedHandler { (commandBuffer) -> Void in
            self.bufferProvider.availableResourcesSemaphore.signal()
        }
        
        // Create an encoder in our command buffer and link it to the pipeline
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
        
        if let texture = self.texture {
            renderEncoder.setFragmentTexture(texture, at: 0)
        }
        if let samplerState = samplerState {
            renderEncoder.setFragmentSamplerState(samplerState, at: 0)
        }
        // Create a model matrix for the current state of the model
        var nodeModelMatrix = self.modelMatrix()
        // Shift the model to the camera perspective (pre-multiply) before passing to the GPU for efficiency
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        // Fetch the next available buffer
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, modelViewMatrix: nodeModelMatrix, light: light)
        // Pass the uniforms buffer to both vertex and fragment shaders
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, at: 1)
        renderEncoder.setVertexBuffer(self.vertexBuffer.buffer, offset: self.vertexBuffer.offset, at: 0)
        renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
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

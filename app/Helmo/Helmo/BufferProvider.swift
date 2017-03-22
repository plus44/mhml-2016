//
//  BufferProvider.swift
//  Helmo
//
//  Created by Mihnea Rusu on 03/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation
import Metal
import simd

class BufferProvider: NSObject {
    let inflightBuffersCount: Int
    private var uniformsBuffers: [MTLBuffer]
    private var availableBufferIndex: Int = 0
    var availableResourcesSemaphore: DispatchSemaphore
    
    init(device: MTLDevice, inflightBuffersCount: Int) {
        availableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)
        
        let sizeOfUniformsBuffer = MemoryLayout<Float>.size * (float4x4.numberOfElements() * 2) + Light.size()
        self.inflightBuffersCount = inflightBuffersCount
        uniformsBuffers = [MTLBuffer]()
        
        for _ in 0...inflightBuffersCount-1 {
            let uniformsBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: [])
            uniformsBuffers.append(uniformsBuffer)
        }
    }
    
    deinit {
        for _ in 0...self.inflightBuffersCount {
            self.availableResourcesSemaphore.signal()
        }
    }
    
    /**
        Fetch the next available buffer and copy some data into it.
    */
    func nextUniformsBuffer(projectionMatrix: float4x4, modelViewMatrix: float4x4, light: Light) -> MTLBuffer {
        
        let buffer = uniformsBuffers[availableBufferIndex]
        let bufferPointer = buffer.contents()
        
        var modelViewMatrix = modelViewMatrix
        var projectionMatrix = projectionMatrix
        
        memcpy(bufferPointer, &modelViewMatrix, MemoryLayout<Float>.size * float4x4.numberOfElements())
        memcpy(bufferPointer + MemoryLayout<Float>.size * float4x4.numberOfElements(), &projectionMatrix, MemoryLayout<Float>.size * float4x4.numberOfElements())
        memcpy(bufferPointer + MemoryLayout<Float>.size * 2 * float4x4.numberOfElements(), light.raw(), Light.size())
        
        availableBufferIndex = availableBufferIndex + 1
        if availableBufferIndex == inflightBuffersCount {
            availableBufferIndex = 0
        }
        
        return buffer
    }
}

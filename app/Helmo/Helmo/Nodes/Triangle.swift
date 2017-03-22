//
//  Triangle.swift
//  Helmo
//
//  Created by Mihnea Rusu on 03/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation
import MetalKit

class Triangle: Node {
    
    init(device: MTLDevice, commandQueue: MTLCommandQueue, textureLoader: MTKTextureLoader) {
        
        let v0 = Vertex(x: 0.0, y: 1.0, z: 0.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, s: 0.5, t: 0.0, nX: 0.0, nY: 0.0, nZ: 1.0)
        let v1 = Vertex(x: -1.0, y: -1.0, z: 0.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, s: 0.0, t: 1.0, nX: 0.0, nY: 0.0, nZ: 1.0)
        let v2 = Vertex(x: 1.0, y: -1.0, z: 0.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, s: 1.0, t: 1.0, nX: 0.0, nY: 0.0, nZ: 1.0)
        
        let verticesArr = [v0, v1, v2]
        
        let image = UIImage(named: "triangle")?.cgImage
        let texture = try! textureLoader.newTexture(with: image!, options: [MTKTextureLoaderOptionSRGB : (false as NSNumber)])
        
        super.init(name: "Triangle", vertices: verticesArr, device: device, texture: texture)
    }
}

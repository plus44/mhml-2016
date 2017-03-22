//
//  Cube.swift
//  Helmo
//
//  Created by Mihnea Rusu on 03/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation
import MetalKit

class Cube: Node {
    
    init(device: MTLDevice, commandQueue: MTLCommandQueue, textureLoader: MTKTextureLoader) {
        
        //Front
        let a = Vertex(x: -1.0, y:   1.0, z:   1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.25, t: 0.25, nX: 0.0, nY: 0.0, nZ: 1.0)
        let b = Vertex(x: -1.0, y:  -1.0, z:   1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.25, t: 0.50, nX: 0.0, nY: 0.0, nZ: 1.0)
        let c = Vertex(x:  1.0, y:  -1.0, z:   1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.50, t: 0.50, nX: 0.0, nY: 0.0, nZ: 1.0)
        let d = Vertex(x:  1.0, y:   1.0, z:   1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 0.50, t: 0.25, nX: 0.0, nY: 0.0, nZ: 1.0)
        
        //Left
        let e = Vertex(x: -1.0, y:   1.0, z:  -1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.00, t: 0.25, nX: -1.0, nY: 0.0, nZ: 0.0)
        let f = Vertex(x: -1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.00, t: 0.50, nX: -1.0, nY: 0.0, nZ: 0.0)
        let g = Vertex(x: -1.0, y:  -1.0, z:   1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.25, t: 0.50, nX: -1.0, nY: 0.0, nZ: 0.0)
        let h = Vertex(x: -1.0, y:   1.0, z:   1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 0.25, t: 0.25, nX: -1.0, nY: 0.0, nZ: 0.0)
        
        //Right
        let i = Vertex(x:  1.0, y:   1.0, z:   1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.50, t: 0.25, nX: 1.0, nY: 0.0, nZ: 0.0)
        let j = Vertex(x:  1.0, y:  -1.0, z:   1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.50, t: 0.50, nX: 1.0, nY: 0.0, nZ: 0.0)
        let k = Vertex(x:  1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.75, t: 0.50, nX: 1.0, nY: 0.0, nZ: 0.0)
        let l = Vertex(x:  1.0, y:   1.0, z:  -1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 0.75, t: 0.25, nX: 1.0, nY: 0.0, nZ: 0.0)
        
        //Top
        let m = Vertex(x: -1.0, y:   1.0, z:  -1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.25, t: 0.00, nX: 0.0, nY: 1.0, nZ: 0.0)
        let n = Vertex(x: -1.0, y:   1.0, z:   1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.25, t: 0.25, nX: 0.0, nY: 1.0, nZ: 0.0)
        let o = Vertex(x:  1.0, y:   1.0, z:   1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.50, t: 0.25, nX: 0.0, nY: 1.0, nZ: 0.0)
        let p = Vertex(x:  1.0, y:   1.0, z:  -1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 0.50, t: 0.00, nX: 0.0, nY: 1.0, nZ: 0.0)
        
        //Bot
        let q = Vertex(x: -1.0, y:  -1.0, z:   1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.25, t: 0.50, nX: 0.0, nY: -1.0, nZ: 0.0)
        let r = Vertex(x: -1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.25, t: 0.75, nX: 0.0, nY: -1.0, nZ: 0.0)
        let s = Vertex(x:  1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.50, t: 0.75, nX: 0.0, nY: -1.0, nZ: 0.0)
        let t = Vertex(x:  1.0, y:  -1.0, z:   1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 0.50, t: 0.50, nX: 0.0, nY: -1.0, nZ: 0.0)
        
        //Back
        let u = Vertex(x:  1.0, y:   1.0, z:  -1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.75, t: 0.25, nX: 0.0, nY: 0.0, nZ: -1.0)
        let v = Vertex(x:  1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.75, t: 0.50, nX: 0.0, nY: 0.0, nZ: -1.0)
        let w = Vertex(x: -1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 1.00, t: 0.50, nX: 0.0, nY: 0.0, nZ: -1.0)
        let x = Vertex(x: -1.0, y:   1.0, z:  -1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 1.00, t: 0.25, nX: 0.0, nY: 0.0, nZ: -1.0)
        
        
        let verticesArray: Array<Vertex> = [
            a, b, c,    a, c, d,    // Front
            e, f, g,    e, g, h,    // Left
            
            i, j, k,    i, k, l,    // Right
            m, n, o,    m, o, p,    // Top
            
            q, r, s,    q, s, t,    // Bottom
            u, v, w,    u, w, x     // Back
        ]
        
        let image = UIImage(named: "cube")?.cgImage
        let texture = try! textureLoader.newTexture(with: image!, options: [MTKTextureLoaderOptionSRGB : (false as NSNumber)])
        
        super.init(name: "Cube", vertices: verticesArray, device: device, texture: texture)
    }
    
    override func updateWith(delta: CFTimeInterval) {
        super.updateWith(delta: delta)
        
        let secsPerMove: Float = 6.0
        rotY = Float(time) * 2.0 * Float(M_PI) / secsPerMove
        // rotX = sinf(Float(time) * 2.0 * Float(M_PI) / secsPerMove)
    }
}

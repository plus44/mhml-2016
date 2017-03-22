//
//  Vertex.swift
//  Helmo
//
//  Created by Mihnea Rusu on 02/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation

struct Vertex {
    
    var x, y, z: Float      // Position data
    var r, g, b, a: Float   // Color data
    var s, t: Float         // Texture coordinates
    var nX, nY, nZ: Float   // Normals
    
    func floatBuffer() -> [Float] {
        return [x, y, z, r, g, b, a, s, t, nX, nY, nZ]
    }
}

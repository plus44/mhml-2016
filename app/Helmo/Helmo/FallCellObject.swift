//
//  FallCellObject.swift
//  Helmo
//
//  Created by Mihnea Rusu on 09/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct FallCellObject: CustomStringConvertible {
    var timestamp: CFTimeInterval! = nil
    var severity: Int! = nil
    var dataURL: String! = nil
    var offset: Int! = nil
    
    var description: String {
        return "\nFall at offset \(offset)\n" +
               "Timestamp: \(timestamp)\n" +
               "Severity: \(severity)\n" +
               "Data URL: \(dataURL)\n"
    }
    
    init(json: JSON) {
        timestamp = json["timestamp"].doubleValue
        dataURL = json["data_url"].stringValue
        offset = json["offset"].intValue
    }
}

//
//  TabBarViewController.swift
//  Helmo
//
//  Created by Mihnea Rusu on 08/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation
import UIKit

class BaseTabBarController: UITabBarController {
    var btManager: BluetoothManager! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btManager = BluetoothManager()
        
        self.selectedIndex = 1
    }
}

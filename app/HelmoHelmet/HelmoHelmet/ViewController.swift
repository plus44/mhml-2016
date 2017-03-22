//
//  ViewController.swift
//  HelmoHelmet
//
//  Created by Mihnea Rusu on 14/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var dialogIsShowing = false
    var isConnected = false
    var coreMotionModel: CoreMotionTestModel! = nil
    var bluetoothManager: BluetoothManager! = nil
    
    @IBOutlet weak var graphView: GraphView!
    
    @IBAction func connectButtonPressed(_ sender: UIButton) {
        if isConnected {
            sender.setTitle("Connect", for: .normal)
            isConnected = false
            graphView.connectionIndicator = .disconnected
            
            bluetoothManager.stopAdvertising()
        } else {
            sender.setTitle("Disconnect", for: .normal)
            isConnected = true
            graphView.connectionIndicator = .connected
            
            bluetoothManager.startAdvertising()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        coreMotionModel = CoreMotionTestModel()
        bluetoothManager = BluetoothManager()
        
        graphView.dataSource = coreMotionModel
        coreMotionModel.delegate = self
        coreMotionModel.startUpdates {
            self.graphView.setNeedsDisplay()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // coreMotionModel.stopUpdates()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: CoreMotionTestModelDelegate {
    func fallDetected(_ sender: CoreMotionTestModel, state: Bool) {
        
        guard !dialogIsShowing else {
            return
        }
        
        guard state else {
            return
        }
        
        DispatchQueue.main.sync {
            let alertController = UIAlertController(title: "Fall detected", message: "Are you okay? Press OK to dismiss or Alert to alert your physician.", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
            let DestructiveAction = UIAlertAction(title: "Alert", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                print("Alert")
                self.dialogIsShowing = false
            }
            
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                self.dialogIsShowing = false
            }
            
            alertController.addAction(DestructiveAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            self.dialogIsShowing = true
        }
    }
    
    func updatedDeviceMotion(_ sender: CoreMotionTestModel, deviceMotionData: CMDeviceMotion) {
        
    }
}


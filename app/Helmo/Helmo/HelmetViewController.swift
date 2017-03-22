//
//  HelmetViewController.swift
//  Helmo
//
//  Created by Mihnea Rusu on 07/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation
import UIKit
import MetalKit
import CoreMotion

struct MetalAttitude {
    var yaw, pitch, roll: Double
    
    init() {
        yaw = 0.0
        pitch = 0.0
        roll = 0.0
    }
}

class HelmetViewController: HelmetSceneViewController {
    
    @IBOutlet weak var faceView: HelmoFaceView!
    @IBOutlet weak var promptConnectLabel: UILabel!
    
    var btManager: BluetoothManager!
    var attitude = MetalAttitude()
    
    @IBAction func faceClicked(_ sender: UIButton) {
        if !faceView.isHidden {
            hideLabelAndFaceView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Load from tab bar controller
        let baseTabBarController = self.tabBarController as! BaseTabBarController
        btManager = baseTabBarController.btManager
        
        mtkView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(HelmetViewController.applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(HelmetViewController.applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        setupFaceView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        if !btManager.isConnected {
            startFaceViewAnimation()
            showLabelAndFaceView()
        } else {
            hideLabelAndFaceView()
            stopFaceViewAnimation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        btManager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        btManager.delegate = nil
        stopFaceViewAnimation()
    }
    
    /**
        Called when the application becomes active again
    */
    func applicationWillEnterForeground(notification: NSNotification) {
        
        startFaceViewAnimation()
    }
    
    /**
        Called after the application has entered background
    */
    func applicationDidEnterBackground(notification: NSNotification) {
        stopFaceViewAnimation()
    }
    
    /**
        Sets the scale and translation of the faceView
    */
    func setupFaceView() {
        faceView.scaleX = 1.2
        faceView.scaleY = 1.2
        faceView.tX = (faceView.frame.midX - faceView.frame.minX) - faceView.w/2
        faceView.tY = 3*(faceView.frame.midY - faceView.frame.minY)/4 - faceView.h/2
    }
    
    /**
        Starts animating the face view
    */
    func startFaceViewAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 0.5
        pulseAnimation.fromValue = 0
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = FLT_MAX
        faceView.layer.add(pulseAnimation, forKey: "animateOpacity")
    }
    
    /**
        Stops animating the face view
    */
    func stopFaceViewAnimation() {
        faceView.layer.removeAnimation(forKey: "animateOpacity")
    }
    
    /**
        Hide label and face view, show the 3D view
    */
    func hideLabelAndFaceView() {
        mtkView.isHidden = false
        mtkView.isPaused = false
    
        faceView.isHidden = true
        promptConnectLabel.isHidden = true
    }
    
    /**
        Show the label and face view, hide the 3D view
    */
    func showLabelAndFaceView() {
        mtkView.isHidden = true
        mtkView.isPaused = true
        
        faceView.isHidden = false
        promptConnectLabel.isHidden = false
    }
}

extension HelmetViewController: BluetoothManagerDelegate {
    func connectedToHelmet(btManager: BluetoothManager) {
        hideLabelAndFaceView()
        stopFaceViewAnimation()
    }
    
    func disconnectedFromHelmet(btManager: BluetoothManager) {
        startFaceViewAnimation()
        showLabelAndFaceView()
    }
    
    func receivedUpdate(btManager: BluetoothManager, characteristicType: HelmetCharacteristic, value: Data) {
        print("received notification update!")
        
        switch characteristicType {
        case .fallDetected:
            print("fall detected changed")
            break
        case .yaw:
            attitude.yaw = value.to(type: Double.self)
            break
        case .pitch:
            attitude.pitch = value.to(type: Double.self)
            break
        case .roll:
            attitude.roll = value.to(type: Double.self)
            break
        default:
            break
        }
    }
}

extension HelmetViewController: HelmetSceneViewControllerDataSource {
    func updateAttitude(_ sender: HelmetSceneViewController) -> MetalAttitude {
        return attitude
    }
}

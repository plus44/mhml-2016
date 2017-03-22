//
//  BluetoothManager.swift
//  HelmoHelmet
//
//  Created by Mihnea Rusu on 14/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreMotion

extension Data {
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}

private enum ServiceUUID: String {
    // MARK: Service UUIDs
    case fall = "3D21"
}

private enum CharacteristicUUID: String {
    // MARK: Fall service characteristic UUIDs
    case fallFallDetected = "78C03976-B317-4DA1-B2FE-1D16E8596E3C"
    case fallAccX = "9FD4682B-D43E-437E-8A11-6055625DD78D"
    case fallAccY = "5885C71B-AD26-4F28-9F21-C780C093CB55"
    case fallAccZ = "289AE599-78B2-4F53-946A-8ED5C6DA3256"
    case fallYaw = "7FC26C21-8CF4-48E7-AC9B-54D0DBB10235"
    case fallPitch = "E2EB7B91-C28E-499A-926C-57515CA4AC94"
    case fallRoll = "B21803D3-DA7C-46EA-ABC4-01055447454B"
}

struct FallServiceData {
    var fallDetected: Bool
    var accX, accY, accZ: Double
    var yaw, pitch, roll: Double
    
    init() {
        fallDetected = false
        
        accX = 0.0
        accY = 0.0
        accZ = 0.0
        
        yaw = 0.0
        pitch = 0.0
        roll = 0.0
    }
    
    var fallDetectedData: Data {
        get {
            return Data(from: self.fallDetected)
        }
    }
    
    var accXData: Data {
        get {
            return Data(from: self.accX)
        }
    }
    
    var accYData: Data {
        get {
            return Data(from: self.accY)
        }
    }
    
    var accZData: Data {
        get {
            return Data(from: self.accZ)
        }
    }
    
    var yawData: Data {
        get {
            return Data(from: self.yaw)
        }
    }
    
    var pitchData: Data {
        get {
            return Data(from: self.pitch)
        }
    }
    
    var rollData: Data {
        get {
            return Data(from: self.roll)
        }
    }
}

class BluetoothManager: NSObject {
    

    let peripheralName = "Helmo"
    let fallServiceUUID = CBUUID(string: ServiceUUID.fall.rawValue)
    let fallFallDetectedCharacteristicUUID = CBUUID(string: CharacteristicUUID.fallFallDetected.rawValue)
    let fallAccXCharacteristicUUID = CBUUID(string: CharacteristicUUID.fallAccX.rawValue)
    let fallAccYCharacteristicUUID = CBUUID(string: CharacteristicUUID.fallAccY.rawValue)
    let fallAccZCharacteristicUUID = CBUUID(string: CharacteristicUUID.fallAccZ.rawValue)
    let fallYawCharacteristicUUID = CBUUID(string: CharacteristicUUID.fallYaw.rawValue)
    let fallPitchCharacteristicUUID = CBUUID(string: CharacteristicUUID.fallPitch.rawValue)
    let fallRollCharacteristicUUID = CBUUID(string: CharacteristicUUID.fallRoll.rawValue)
    
    
    var peripheralManager: CBPeripheralManager! = nil
    var fallService: CBMutableService! = nil
    var fallServiceData = FallServiceData()
    var fallFallDetectedCharacteristic: CBMutableCharacteristic! = nil
    var fallAccXCharacteristic: CBMutableCharacteristic! = nil
    var fallAccYCharacteristic: CBMutableCharacteristic! = nil
    var fallAccZCharacteristic: CBMutableCharacteristic! = nil
    var fallYawCharacteristic: CBMutableCharacteristic! = nil
    var fallPitchCharacteristic: CBMutableCharacteristic! = nil
    var fallRollCharacteristic: CBMutableCharacteristic! = nil
    
    override init() {
        super.init()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        let characteristicProperties: CBCharacteristicProperties = [.notify, .read]
        let permissions: CBAttributePermissions = [.readable]
        
        
        fallService = CBMutableService(type: fallServiceUUID, primary: true)
        
        fallFallDetectedCharacteristic = CBMutableCharacteristic(type: fallFallDetectedCharacteristicUUID, properties: characteristicProperties, value: nil, permissions: permissions)
        
        fallAccXCharacteristic = CBMutableCharacteristic(type: fallAccXCharacteristicUUID, properties: characteristicProperties, value: nil, permissions: permissions)
        fallAccYCharacteristic = CBMutableCharacteristic(type: fallAccYCharacteristicUUID, properties: characteristicProperties, value: nil, permissions: permissions)
        fallAccZCharacteristic = CBMutableCharacteristic(type: fallAccZCharacteristicUUID, properties: characteristicProperties, value: nil, permissions: permissions)
        
        fallYawCharacteristic = CBMutableCharacteristic(type: fallYawCharacteristicUUID, properties: characteristicProperties, value: nil, permissions: permissions)
        fallPitchCharacteristic = CBMutableCharacteristic(type: fallPitchCharacteristicUUID, properties: characteristicProperties, value: nil, permissions: permissions)
        fallRollCharacteristic = CBMutableCharacteristic(type: fallRollCharacteristicUUID, properties: characteristicProperties, value: nil, permissions: permissions)

        fallService.characteristics = [fallFallDetectedCharacteristic, fallAccXCharacteristic, fallAccYCharacteristic, fallAccZCharacteristic, fallYawCharacteristic, fallPitchCharacteristic, fallRollCharacteristic]
        peripheralManager.add(fallService)
        

    }
    
    func startAdvertising() {
        let advertisementData = [CBAdvertisementDataLocalNameKey: peripheralName, CBAdvertisementDataServiceUUIDsKey: [fallServiceUUID]] as [String: Any]
        
        peripheralManager.startAdvertising(advertisementData)
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }
}

extension BluetoothManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("Bluetooth state updated: \(peripheral.state)")
        
        switch peripheral.state {
        case .poweredOff:
            break
        case .poweredOn:
            print("Bluetooth is on!")
        case .resetting:
            break
        case .unauthorized:
            break
        case .unknown:
            break
        case .unsupported:
            break
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?)
    {
        if let error = error {
            print("Failed advertising with error: \(error)")
            return
        }
        print("Succeeded advertising!")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        switch characteristic.uuid.uuidString {
        case fallFallDetectedCharacteristicUUID.uuidString:
            print("Central subscribed to fall detected.")
            break
        case fallAccXCharacteristicUUID.uuidString:
            print("Central subscribed to accX.")
            break
        case fallAccYCharacteristicUUID.uuidString:
            print("Central subscribed to accY.")
            break
        case fallAccZCharacteristicUUID.uuidString:
            print("Central subscribed to accZ.")
            break
        case fallYawCharacteristicUUID.uuidString:
            print("Central subscribed to yaw.")
            break
        case fallPitchCharacteristicUUID.uuidString:
            print("Central subscribed to pitch.")
            break
        case fallRollCharacteristicUUID.uuidString:
            print("Central subscribed to roll.")
            break
            
        default:
            print("Central subscribed to unknown characteristic.")
            break
        }
    }

}

extension BluetoothManager: CoreMotionTestModelDelegate {
    func fallDetected(_ sender: CoreMotionTestModel, state: Bool) {
        
        fallServiceData.fallDetected = state
        
        fallFallDetectedCharacteristic.value = fallServiceData.fallDetectedData
        
        peripheralManager.updateValue(fallFallDetectedCharacteristic.value!, for: fallFallDetectedCharacteristic, onSubscribedCentrals: nil)
    }
    
    func updatedDeviceMotion(_ sender: CoreMotionTestModel, deviceMotionData: CMDeviceMotion) {
        
        fallServiceData.accX = deviceMotionData.userAcceleration.x
        fallServiceData.accY = deviceMotionData.userAcceleration.y
        fallServiceData.accZ = deviceMotionData.userAcceleration.z
        fallServiceData.yaw = deviceMotionData.attitude.yaw
        fallServiceData.pitch = deviceMotionData.attitude.pitch
        fallServiceData.roll = deviceMotionData.attitude.roll
        
        fallAccXCharacteristic.value = fallServiceData.accXData
        fallAccYCharacteristic.value = fallServiceData.accYData
        fallAccZCharacteristic.value = fallServiceData.accZData
        fallYawCharacteristic.value = fallServiceData.yawData
        fallPitchCharacteristic.value = fallServiceData.pitchData
        fallRollCharacteristic.value = fallServiceData.rollData
        
        peripheralManager.updateValue(fallAccXCharacteristic.value!, for: fallAccXCharacteristic, onSubscribedCentrals: nil)
        peripheralManager.updateValue(fallAccYCharacteristic.value!, for: fallAccYCharacteristic, onSubscribedCentrals: nil)
        peripheralManager.updateValue(fallAccZCharacteristic.value!, for: fallAccZCharacteristic, onSubscribedCentrals: nil)
        peripheralManager.updateValue(fallYawCharacteristic.value!, for: fallYawCharacteristic, onSubscribedCentrals: nil)
        peripheralManager.updateValue(fallPitchCharacteristic.value!, for: fallPitchCharacteristic, onSubscribedCentrals: nil)
        peripheralManager.updateValue(fallRollCharacteristic.value!, for: fallRollCharacteristic, onSubscribedCentrals: nil)
    }
    
}

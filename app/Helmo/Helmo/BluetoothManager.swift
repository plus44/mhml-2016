//
//  BluetoothManager.swift
//  Helmo
//
//  Created by Mihnea Rusu on 07/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import CoreBluetooth
import Foundation

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

enum HelmetCharacteristic {
    case fallDetected
    case accX, accY, accZ
    case yaw, pitch, roll
}

protocol BluetoothManagerDelegate: class {
    func connectedToHelmet(btManager: BluetoothManager)
    func disconnectedFromHelmet(btManager: BluetoothManager)
    func receivedUpdate(btManager: BluetoothManager, characteristicType: HelmetCharacteristic, value: Data)
}

class BluetoothManager: NSObject {
    fileprivate var centralManager: CBCentralManager! = nil
    fileprivate var helmetPeripheral: CBPeripheral? = nil
    fileprivate var fallService: CBService! = nil
    
    fileprivate var fallFallDetectedCharacteristic: CBCharacteristic! = nil
    
    fileprivate var fallAccXCharacteristic: CBCharacteristic! = nil
    fileprivate var fallAccYCharacteristic: CBCharacteristic! = nil
    fileprivate var fallAccZCharacteristic: CBCharacteristic! = nil
    
    fileprivate var fallYawCharacteristic: CBCharacteristic! = nil
    fileprivate var fallPitchCharacteristic: CBCharacteristic! = nil
    fileprivate var fallRollCharacteristic: CBCharacteristic! = nil
    
    var isConnected = false
    weak var delegate: BluetoothManagerDelegate! = nil
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        // discoverDevice()
    }
    
    func discoverDevice() {
        print("Starting Bluetooth scan")
        let fallServiceUUID = CBUUID(string: ServiceUUID.fall.rawValue)
        centralManager.scanForPeripherals(withServices: [fallServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    /**
        Called when the Bluetooth connection status changes
    */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch(central.state) {
        case .poweredOff:
            break
        case .poweredOn:
            print("Bluetooth is on")
            // Start scanning for devices
            discoverDevice()
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
    
    /**
        Called when a peripheral has been discovered from a search, that has
        the services we told it to look for
    */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    
        guard helmetPeripheral == nil else {
            return
        }
       
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        {
            print("peripheral name = \(peripheralName)")
            if peripheralName == "Helmo" {
                
                if let services = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
                    print("advertised services: \(services)")
                }
                
                helmetPeripheral = peripheral
                
                // Connect to this peripheral
                centralManager.connect(peripheral, options: nil)
            }
        }
        
    }
    
    /**
        Called when a peripheral connection has been established
    */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to phone")
        peripheral.delegate = self
        delegate.connectedToHelmet(btManager: self)
        isConnected = true
        centralManager.stopScan()
        // Discover the services of this peripheral
        peripheral.discoverServices([CBUUID(string: ServiceUUID.fall.rawValue)])
    }
    
    /**
        Called when a peripheral has been disconnected
    */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        guard peripheral.name == "Helmo" else {
            return
        }
        
        print("Disconnected from helmet")
        // Invalidate the references we stored of the peripheral
        fallFallDetectedCharacteristic = nil
        fallAccXCharacteristic = nil
        fallAccYCharacteristic = nil
        fallAccZCharacteristic = nil
        fallYawCharacteristic = nil
        fallPitchCharacteristic = nil
        fallRollCharacteristic = nil
        fallService = nil
        helmetPeripheral = nil
        
        delegate.disconnectedFromHelmet(btManager: self)
        discoverDevice()
    }
    
    
}

extension BluetoothManager: CBPeripheralDelegate {
    /**
        Called when the services of a peripheral have been discovered.
    */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered the services in our SoC.")
        for service in peripheral.services! {
            print("Service: \(service)")
            print("Service characteristics: \(service.characteristics)")
            
            if service.uuid.uuidString == ServiceUUID.fall.rawValue {
                print("Helmet service found")
                fallService = service
                
                // Discover characteristics of this service
                peripheral.discoverCharacteristics(nil, for: fallService)
            }
        }
    }
    
    
    /**
        Called when the characteristics have been discovered.
    */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        for characteristic in service.characteristics! {
            print("Found characteristic: \(characteristic)")
            switch characteristic.uuid.uuidString {
            case CharacteristicUUID.fallFallDetected.rawValue:
                fallFallDetectedCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                break
            case CharacteristicUUID.fallAccX.rawValue:
                fallAccXCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                break
            case CharacteristicUUID.fallAccY.rawValue:
                fallAccYCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                break
            case CharacteristicUUID.fallAccZ.rawValue:
                fallAccZCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                break
            case CharacteristicUUID.fallYaw.rawValue:
                fallYawCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                break
            case CharacteristicUUID.fallPitch.rawValue:
                fallPitchCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                break
            case CharacteristicUUID.fallRoll.rawValue:
                fallRollCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                break
            }
        }
    }
    
    /**
        Called when a value update notification has been received for a characteristic
    */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        switch characteristic.uuid.uuidString {
        case CharacteristicUUID.fallFallDetected.rawValue:
            if let val = characteristic.value {
                delegate?.receivedUpdate(btManager: self, characteristicType: .fallDetected, value: val)
            }
            break
        case CharacteristicUUID.fallAccX.rawValue:
            if let val = characteristic.value {
                delegate?.receivedUpdate(btManager: self, characteristicType: .accX, value: val)
            }
            break
        case CharacteristicUUID.fallAccY.rawValue:
            if let val = characteristic.value {
                delegate?.receivedUpdate(btManager: self, characteristicType: .accY, value: val)
            }
            break
        case CharacteristicUUID.fallAccZ.rawValue:
            if let val = characteristic.value {
                delegate?.receivedUpdate(btManager: self, characteristicType: .accZ, value: val)
            }
            break
        case CharacteristicUUID.fallYaw.rawValue:
            if let val = characteristic.value {
                delegate?.receivedUpdate(btManager: self, characteristicType: .yaw, value: val)
            }
            break
        case CharacteristicUUID.fallPitch.rawValue:
            if let val = characteristic.value {
                delegate?.receivedUpdate(btManager: self, characteristicType: .pitch, value: val)
            }
            break
        case CharacteristicUUID.fallRoll.rawValue:
            if let val = characteristic.value {
                delegate?.receivedUpdate(btManager: self, characteristicType: .roll, value: val)
            }
        default:
            break
        }
    }
}

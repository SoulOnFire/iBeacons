//
//  AppDelegate.swift
//  iBeacons
//
//  Created by Fernando Miguel Oliveira Duarte on 27/01/16.
//  Copyright © 2016 AS. All rights reserved.
//

import Cocoa
import CoreBluetooth
import CoreLocation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CBPeripheralManagerDelegate {
    var manager : CBPeripheralManager!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        //self.manager = CBPeripheralManager(delegate: self, queue: nil)

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager){
        if(peripheral.state == .PoweredOn){
            let uuid = NSUUID(UUIDString: "00000000-0000-0000-0000-000000000001")!
            
            let b = BLE(uuid: uuid, major: 123, minor: 321)
            let b1 = BLE(uuid: uuid, major: 222, minor: 333)
            peripheral.startAdvertising(b.beaconAdvertisement())
            peripheral.startAdvertising(b1.beaconAdvertisement())
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?){
        print("Starting... \(peripheral)")
    }
    

}

class BLE: NSObject {
    var uuid:NSUUID
    var major: UInt16
    var minor: UInt16
    var measuredPower: Int8 = -59
    var state: CBPeripheralManagerState = .Unknown
    init(uuid:NSUUID, major: UInt16, minor: UInt16) {
        self.uuid = uuid
        self.major = major
        self.minor = minor
        super.init()
    }
    
    func beaconAdvertisement() -> [String : AnyObject] {
        let beaconKey: String = "kCBAdvDataAppleBeaconKey"
        let advertisementBytes: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.alloc(21)
        self.uuid.getUUIDBytes(advertisementBytes)
        advertisementBytes[16] = UInt8(self.major >> 8)
        advertisementBytes[17] = UInt8(self.major & 255)
        advertisementBytes[18] = UInt8(self.minor >> 8)
        advertisementBytes[19] = UInt8(self.minor & 255)
        advertisementBytes[20] = UInt8(bitPattern: self.measuredPower)
        let advertisement = NSMutableData(bytes: advertisementBytes, length: 21)
        return [beaconKey : advertisement]
    }
}
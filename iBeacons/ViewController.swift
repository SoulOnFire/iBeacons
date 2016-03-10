//
//  ViewController.swift
//  iBeacons
//
//  Created by Fernando Miguel Oliveira Duarte on 27/01/16.
//  Copyright © 2016 AS. All rights reserved.
//

import Cocoa
import CoreLocation
import CoreBluetooth

class ViewController: NSViewController {
    var manager: CBPeripheralManager?
    var beacons :[BLE]?
    var selectedBeacon: BLE?
    var advertisedBeacon: BLE?
    let uuid = NSUUID(UUIDString: "00000000-0000-0000-0000-000000000001")!
    override func viewDidLoad() {
        super.viewDidLoad()
        let b = BLE(uuid: uuid, major: 123, minor: 321)
        let b1 = BLE(uuid: uuid, major: 222, minor: 333)
        self.beacons = []
        self.beacons?.append(b)
        self.beacons?.append(b1)
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var uuidTextField: NSTextField!
    @IBOutlet weak var majorTextField: NSTextField!
    @IBOutlet weak var minorTextField: NSTextField!
    @IBOutlet weak var stateButton: NSButton!
    
    @IBAction func add(sender: AnyObject) {
        self.beacons?.append(BLE(uuid: uuid, major: 0, minor: 0))
        self.tableView.reloadData()
        self.tableView.selectRowIndexes(NSIndexSet(index: (self.beacons?.count ?? 0) - 1), byExtendingSelection: false)
    }
    @IBAction func remove(sender: AnyObject) {
        if let beacon = self.selectedBeacon,
            let index = self.beacons?.indexOf(beacon){
                self.beacons?.removeAtIndex(index)
                self.tableView.reloadData()
                self.selectedBeacon = nil
                self.updateUI()
                self.tableView.selectRowIndexes(NSIndexSet(index: index - 1), byExtendingSelection: false)
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        if let id = NSUUID(UUIDString: self.uuidTextField.stringValue),
            let major = UInt16(self.majorTextField.stringValue),
            let minor = UInt16(self.minorTextField.stringValue){
                self.selectedBeacon?.uuid = id
                self.selectedBeacon?.major = major
                self.selectedBeacon?.minor = minor
                self.tableView.reloadData()
        }
    }
    
    @IBAction func stateChange(sender: AnyObject) {
        
        guard let beacon = self.selectedBeacon else { return }
        if beacon.state == .Unknown {
            self.advertisedBeacon?.state = .Unknown
            self.manager?.stopAdvertising()
            self.manager = CBPeripheralManager(delegate: self, queue: nil)
        }else {
            self.advertisedBeacon?.state = .Unknown
            self.manager?.stopAdvertising()
            self.manager = nil
        }
        self.tableView.reloadData()
        self.updateUI()
    }
    
    func updateUI(){
        if let beacon = self.selectedBeacon {
            self.uuidTextField.stringValue = beacon.uuid.UUIDString
            self.majorTextField.stringValue = "\(beacon.major)"
            self.minorTextField.stringValue = "\(beacon.minor)"
            
            if beacon.state == CBPeripheralManagerState.Unknown {
                self.stateButton.title = "Start"
            }
            else {
                self.stateButton.title = "Stop"
            }
        }else {
            self.uuidTextField.stringValue = ""
            self.majorTextField.stringValue = ""
            self.minorTextField.stringValue = ""
            self.stateButton.title = "Start"
        }
        
    }
    @IBAction func generateUUID(sender: AnyObject) {
        self.uuidTextField.stringValue = NSUUID.init().UUIDString
    }
}

extension ViewController: CBPeripheralManagerDelegate{
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager){
        if(peripheral.state == .PoweredOn){
            if let beacon = self.selectedBeacon {
                peripheral.startAdvertising(beacon.beaconAdvertisement())
                self.advertisedBeacon = beacon
            }
        }
        self.advertisedBeacon?.state = peripheral.state
        self.updateUI()
        self.tableView.reloadData()
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?){
        print("Starting... \(peripheral)")
    }
    
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        return self.beacons?.count ?? 0
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as? NSTableCellView ,
            let beacon = self.beacons?[row] where tableColumn?.identifier == "BeaconsColumn"{
                cellView.textField?.stringValue = "\(beacon.uuid.UUIDString)\nMajor: \(beacon.major)\tMinor: \(beacon.minor)"
                
                if beacon.state == CBPeripheralManagerState.Unknown {
                    cellView.imageView?.image = NSImage(imageLiteral: "NSStatusNone")
                }
                else {
                    cellView.imageView?.image = NSImage(imageLiteral: "NSStatusAvailable")
                }
                return cellView
        }
        return nil
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        self.selectedBeacon = self.beacons?[self.tableView.selectedRow]
        self.updateUI()
    }
}
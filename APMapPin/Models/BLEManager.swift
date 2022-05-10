//
//  BLEManager.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/12/22.
//

import Foundation
import CoreBluetooth
import SwiftUI
import WatchConnectivity

enum SendState{
    case WaitingForAck
    case ReadyToSend
}
struct Peripheral: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
    }

struct CBUUIDs{

    static let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

}



class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var messageReceivedFromAPDelegate: ReceiveApMessageDelegate!
    var mapMessageDelegate: MapMessageDelegate?
    var gvm:GlobalViewModel?
    var myCentral: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    @Published var connectedToAp = false
    @Published var scanning: Bool = false;
    @Published var rcvMessage: String = ""
    @Published var found:Bool = false
    @Published var rcvMsg:String = ""
    var initialized:Bool = false
    var rcvString: String = ""
    var txCharacteristic: CBCharacteristic!
    var rxCharacteristic: CBCharacteristic!
    var stopOn:String = ""
    var foundPeripheral: CBPeripheral?
    var vewIsReady = false
    var peripheralName:String = "Adafruit Bluefruit LE"
    var scanningTimer:Timer?
    var sendState:SendState = SendState.ReadyToSend

    override init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
        
        if WCSession.isSupported(){
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func hasAppeared(gvm:GlobalViewModel){
        if !initialized{
            self.gvm = gvm
        }
        print("in hasAppeared")
        if !vewIsReady{
            startScanning(stopOn: peripheralName)
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { Timer in
                if !self.connectedToAp{
                    self.stopScanning()
                }
            }
        }
        vewIsReady = true
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
         if central.state == .poweredOn {
             isSwitchedOn = true
         }
         else {
             isSwitchedOn = false
         }
    }

    func connect(){
        print("In connect")
        guard foundPeripheral != nil else {
            print("foundPeripheral was nil")
            return
        }
        myCentral.connect(foundPeripheral!, options: nil)
        //connected = true
    }
    
    func disconnect(){
        guard foundPeripheral != nil else {
            return;
        }
        myCentral.cancelPeripheralConnection(foundPeripheral!)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        print("Connected to " + peripheral.name!)
        connectedToAp = true
    }
        
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(peripheral.name! + " Disconnected")
        connectedToAp = false
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
       
        if !scanning {return}
        
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown"
        }
       
        let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue)
        print(newPeripheral)
        if (stopOn.count > 0)
        {
            if newPeripheral.name==stopOn{
                print ("found it")
                if let svcArray = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
                    for svc in svcArray{
                        print(svc)
                    }
                }
                foundPeripheral = peripheral
                found=true
                stopScanning()
                connect()
            }
        }
        //peripherals.append(newPeripheral)
        peripherals.insert(newPeripheral, at: 0)
    }
    
    func startScanning(stopOn:String = ""){
        found = false;
         scanning = true;
         self.stopOn = stopOn
         peripherals = []
//         print("startScanning")
         myCentral.scanForPeripherals(withServices: nil, options: nil)
     }
    
    func stopScanning() {
        scanning = false;
//        print("stopScanning")
        myCentral.stopScan()
    }
    
}

extension BLEManager{
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
//        print("*******************************************************")

        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
//        print("Discovered Services: \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
           
               guard let characteristics = service.characteristics else {
              return
          }

          print("Found \(characteristics.count) characteristics.")

          for characteristic in characteristics {

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {
//              print("Setting rxCharacteristic")
              rxCharacteristic = characteristic

              peripheral.setNotifyValue(true, for: rxCharacteristic!)
              peripheral.readValue(for: characteristic)

//              print("RX Characteristic: \(rxCharacteristic.uuid)")
            }

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
//              print("Setting txCharacteristic")
              txCharacteristic = characteristic
              
//              print("TX Characteristic: \(txCharacteristic.uuid)")
            }
          }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Peripheral Is Powered On.")
        case .unsupported:
            print("Peripheral Is Unsupported.")
        case .unauthorized:
        print("Peripheral Is Unauthorized.")
        case .unknown:
            print("Peripheral Unknown")
        case .resetting:
            print("Peripheral Resetting")
        case .poweredOff:
          print("Peripheral Is Powered Off.")
        @unknown default:
          print("Error")
        }
      }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

          var characteristicASCIIValue = NSString()

          guard characteristic == rxCharacteristic,

          let characteristicValue = characteristic.value,
          let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }

          characteristicASCIIValue = ASCIIstring
          rcvString += "\((characteristicASCIIValue as String))"
          if rcvString.contains("<EOM>"){
              print(rcvString)
              rcvMessage=rcvString + "\n\n"
              rcvString = "" // clear it out for the next command
              if messageReceivedFromAPDelegate != nil{
                  messageReceivedFromAPDelegate.messageIn(message: rcvMessage)
              }
              if gvm!.compassCalAPMessageDelegate != nil{
                  gvm!.compassCalAPMessageDelegate!.compassCalAPMessage(message: rcvMessage)
              }
              sendState = .ReadyToSend
              print(sendState)
        }
    }
    
    func sendMessageToAP(data: String){
        print("send: \(data)")
        while sendState == .WaitingForAck{
            sleep(1)
            sendState = .ReadyToSend
        }
        var valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        valueString!.append(("\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        
        if let foundPeripheral = foundPeripheral {
          if let txCharacteristic = txCharacteristic {
              foundPeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
              sendState = .WaitingForAck
              return
              }
          }
        print("writeOutgoingValue error")
      }
}

extension BLEManager : WCSessionDelegate{
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("session DidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("session DidDeactivate")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activation complete \(activationState.rawValue)")
        if let err = error {
            print(err)
        }
    }
    
    func SendWatchMessage(msg:String){
        print("Sending \(msg)")
        WCSession.default.sendMessage(["Message" : msg], replyHandler: nil)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("message received")
        print("\(message)")
        switch message.keys.first{
        case "APMessage":
            if let msgStr = message["APMessage"] as? String{
                if gvm!.navType != NavType.none{
                    DispatchQueue.main.async {
                        self.gvm!.stopNavigation()
                    }
                }
                if connectedToAp{
                    sendMessageToAP(data: msgStr)
                }
            }
            break
        case "MapMessage":
            if let map = mapMessageDelegate{
                if let msgStr = message["MapMessage"] as? String{
                    map.mapMessage(msg:  msgStr)
                }
            }
            break
        default:
            break
        }
        
    }
}


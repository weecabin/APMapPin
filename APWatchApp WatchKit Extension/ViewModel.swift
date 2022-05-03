//
//  ViewModel.swift
//  APWatchApp WatchKit Extension
//
//  Created by Gary Hamann on 4/12/22.
//

import SwiftUI
import WatchConnectivity
import CoreLocation

enum MsgType{
    case ApMsg
    case MapMsg
}

class ViewModel : NSObject, ObservableObject{
    @Published var rcvMsg:String = "?"
    let locationManager = CLLocationManager()
    var lastDeviceHeading:CLHeading?
    var headingAvailableDelegate:HeadingAvailableDelegate?
    var initialized:Bool = false
    let bh:CGFloat = 30
    let bw:CGFloat = 50
    override init(){
        super.init()
        setupCoreLocation()
    }
    func Left(delta:Int){
        SendMessage(msg: "hi-\(delta)")
    }
    func Right(delta:Int){
        SendMessage(msg: "hi\(delta)")
    }
    func Lock(){
        SendMessage(msg: "!B507")
    }
}
extension ViewModel : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager,
                         didUpdateHeading newHeading: CLHeading){
        lastDeviceHeading = newHeading
        if let headingDelegate = headingAvailableDelegate{
            headingDelegate.newHeading(heading: newHeading)
        }
    }
    
    func setupCoreLocation() {
        guard CLLocationManager.headingAvailable() else { return }
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // additional setup available if needed
        locationManager.startUpdatingHeading()
    }
}

extension ViewModel : WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activation complete \(activationState.rawValue)")
        if let err = error {
            print(err)
        }
    }
    
    func SendMessage(msgType:MsgType = .ApMsg, msg:String){
        print("Sending \(msg)")
        switch (msgType){
        case .ApMsg:
            WCSession.default.sendMessage(["APMessage" : msg], replyHandler: nil)
            break
        case .MapMsg:
            WCSession.default.sendMessage(["MapMessage" : msg], replyHandler: nil)
            break
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("message received")
        print("\(message["Message"] ?? "?")")
        if let msgStr = message["Message"] as? String{
            DispatchQueue.main.async { self.rcvMsg = msgStr }
        }
    }
    
    func onTurnViewAppear(){
        if !initialized {
            print("initializing WCSession")
            if WCSession.isSupported(){
                let session = WCSession.default
                session.delegate = self
                session.activate()
            }
            initialized = true
        }
    }
}


//
//  ViewModel.swift
//  APWatchApp WatchKit Extension
//
//  Created by Gary Hamann on 4/12/22.
//

import Foundation
import WatchConnectivity

enum MsgType{
    case ApMsg
    case MapMsg
}

class ViewModel : NSObject, ObservableObject{
    @Published var rcvMsg:String = "?"
    var initialized:Bool = false
    
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
    
    func onAppear(){
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


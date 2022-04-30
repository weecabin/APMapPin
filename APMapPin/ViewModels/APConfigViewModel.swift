//
//  APConfigViewModel.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/12/22.
//

import Foundation
import WatchConnectivity
struct TurnAngle: Identifiable{
    let id:UUID = UUID()
    let name:String
    let value:Int
}

class ApConfigViewModel : ObservableObject{
    
//    @Published var apConfig:APConfigStruct = APConfigStruct()
    @Published  var configItems:[PV] = []
    @Published var editItemId:UUID?
    @Published var editValue:String?
    @Published var actuatorEnabled:Bool = true
    @Published var turnAngles:[TurnAngle] = []
    @Published var turnAngle:Int = 5
    var initialized:Bool = false
    var ble:BLEManager?
    //@Published var apHeading:Float = 0
    
    struct PV: Identifiable{
        let id:UUID = UUID()
        let prompt:String
        let value:String
        let editable:Bool
    }

    func onAppear(ble:BLEManager){
        print("in apvm.onAppear")
        if !initialized{
            self.ble = ble
            loadPicker()
            initialized = true
        }
    }
    
    func toggleActuatorEnabled(){
        print("in toggleActuatorEnabled")
        actuatorEnabled.toggle()
        if actuatorEnabled{
            ble!.sendMessageToAP(data: "sr")
            ble!.sendMessageToAP(data: "!B507")
        }else{
            ble!.sendMessageToAP(data: "ss")
            //ble!.sendMessageToAP(data: "m3")
        }
    }
    
    func configCommand(newValue:String) -> String{
        var command:String = ""
        if let index = editItemIndex(){
            let item = configItems[index]
            switch item.prompt{
            case "Drive(Prop/Incr):":
                if newValue == "Prop"{
                    command = "tp"
                }else{
                    command = "ti"
                }
                break
            case "kp:":
                guard let index = editItemIndex(prompt: "ki:") else {return ""}
                let ki = configItems[index].value
                guard let index = editItemIndex(prompt: "kd:") else {return ""}
                let kd = configItems[index].value
                command = "k\(newValue),\(ki),\(kd)"
                break
                
            case "ki:":
                guard let index = editItemIndex(prompt: "kp:") else {return ""}
                let kp = configItems[index].value
                guard let index = editItemIndex(prompt: "kd:") else {return ""}
                let kd = configItems[index].value
                command = "k\(kp),\(newValue),\(kd)"
                break
                
            case "kd:":
                guard let index = editItemIndex(prompt: "kp:") else {return ""}
                let kp = configItems[index].value
                guard let index = editItemIndex(prompt: "ki:") else {return ""}
                let ki = configItems[index].value
                command = "k\(kp),\(ki),\(newValue)"
                break
                
            case "Offset:":
                command = "so\(newValue)"
                break
                
            case "TargetHeading:":
                command = "ht\(newValue)"
                break
                
            case "CompassCorrection:":
                command = "hc\(newValue)"
                break
                
            case "Position:":
                command = "m\(newValue)"
                break
                
            case "Null Zone:":
                command = "n\(newValue)"
                break
                
            case "limit Move:":
                command = "l\(newValue)"
                break
                
            case "CirclingSeconds:":
                guard let index = editItemIndex(prompt:"CirclingSegments:") else {return""}
                let segments = configItems[index].value
                command = "c\(newValue),\(segments)"
                break
                
            case "CirclingSegments:":
                guard let index = editItemIndex(prompt:"CirclingSeconds:") else {return""}
                let seconds = configItems[index].value
                command = "c\(seconds),\(newValue)"
                break
                
            case "PidInterval:":
                command = "ip\(newValue)"
                break
                
            case "MoveInterval:":
                command = "im\(newValue)"
                break
                
            default:
                command = ""
            }
            return command
        }
        return ""
    }
    
    func loadPicker(){
        var i:Int = 5
        turnAngles = []
        while i<95 {
            turnAngles.append(TurnAngle(name: "\(i)", value: i))
            i = i + 5
        }
    }
    
    func editItemValue() -> String?{
        guard let index = editItemIndex() else{return nil}
        if index == 0 {return ""}
        return configItems[index].value
    }
    
    func editItemPrompt() -> String{
        guard let index = editItemIndex() else{return "??"}
        var prompt = configItems[index].prompt
        if prompt == "CompassCorrection:"{
            prompt = "Heading"
        }
        return prompt
    }
    
    func editItemIndex(prompt:String) -> Int?{
        var index=0
        for item in configItems {
            if item.prompt == prompt {
                return index
            }
            index = index + 1
        }
        return nil
    }
    
    func editItemIndex() -> Int?{
        var index=0
        for item in configItems {
            if item.id == editItemId{
                return index
            }
            index = index+1
        }
        return nil
    }
    
    func updateConfigItems(configString:String){
        configItems=[]
        // Keep CompassCorrection as the first item
        configItems.append(PV(prompt: "CompassCorrection:", value: String(Float(MySubString(src: configString, sub: "CompassCorrection=", returnLen: 7, offset: 18)) ?? 0),editable:true))
        configItems.append(PV(prompt: "Offset:", value: String(Float(MySubString(src: configString, sub: "Offset=", returnLen: 6, offset: 7)) ?? 0),editable:true))
        configItems.append(PV(prompt: "Target:", value: String(Float(MySubString(src: configString, sub: "TargetHeading=", returnLen: 6, offset: 14)) ?? 0),editable:true))
        configItems.append(PV(prompt: "Heading:", value: String(Float(MySubString(src: configString, sub: "CurrentHeading=", returnLen: 6, offset: 15)) ?? 0),editable:false))
        configItems.append(PV(prompt: "Position:", value: String(Float(MySubString(src: configString, sub: "Position=", returnLen: 4, offset: 9)) ?? 0),editable:true))
        configItems.append(PV(prompt: "kp:", value: String(Float(MySubString(src: configString, sub: "kp=", returnLen: 5, offset: 3)) ?? 0),editable:true))
        configItems.append(PV(prompt: "ki:", value: String(Float(MySubString(src: configString, sub: "ki=", returnLen: 5, offset: 3)) ?? 0),editable:true))
        configItems.append(PV(prompt: "kd:", value: String(Float(MySubString(src: configString, sub: "kd=", returnLen: 5, offset: 3)) ?? 0),editable:true))
        configItems.append(PV(prompt: "Null Zone:", value: String(Float(MySubString(src: configString, sub: "Null Zone=", returnLen: 5, occurance: 1, offset: 10)) ?? 0),editable:true))
        configItems.append(PV(prompt: "limit Move:", value: String(Float(MySubString(src: configString, sub: "limit Move=", returnLen: 5, occurance: 1, offset: 11)) ?? 0),editable:true))
        configItems.append(PV(prompt: "CirclingSeconds:", value: String(Int(MySubString(src: configString, sub: "CirclingSeconds=", returnLen: 5, offset: 16)) ?? 0),editable:true))
        configItems.append(PV(prompt: "CirclingSegments:", value: String(Int(MySubString(src: configString, sub: "CirclingSegments=", returnLen: 5, offset: 17)) ?? 0),editable:true))
        configItems.append(PV(prompt: "PidInterval:", value: String(Int(MySubString(src: configString, sub: "PidInterval=", returnLen: 5, occurance: 1, offset: 12)) ?? 0),editable:true))
        configItems.append(PV(prompt: "MoveInterval:", value: String(Int(MySubString(src: configString, sub: "MoveInterval=", returnLen: 5, occurance: 1, offset: 13)) ?? 0),editable:true))
        configItems.append(PV(prompt: "Drive(Prop/Incr):", value: MySubString(src: configString, sub: "Drive=", returnLen: 5, occurance: 1, offset: 6),editable:true))
        for item in configItems{
            print("\(item)")
        }
    }
}



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
            ble!.sendMessageToAP(data: "\(CMD_START_ACTUATOR)")
            ble!.sendMessageToAP(data: "\(CMD_LOCK)")
        }else{
            ble!.sendMessageToAP(data: "\(CMD_STOP_ACTUATOR)")
        }
    }
    
    func configCommand(newValue:String) -> String{
        var command:String = ""
        if let index = editItemIndex(){
            let item = configItems[index]
            switch item.prompt{
            case "AlwaysRunLoop:":
                command = "\(CMD_ALWAYS_RUN_LOOP)\(newValue)"
                break
            case "Drive(Prop/Incr):":
                if newValue == "Prop"{
                    command = "\(CMD_SET_DRIVE_PROPORTIONAL)"
                }else{
                    command = "\(CMD_SET_DRIVE_INCREMENTAL)"
                }
                break
            case "kp:":
                guard let index = editItemIndex(prompt: "ki:") else {return ""}
                let ki = configItems[index].value
                guard let index = editItemIndex(prompt: "kd:") else {return ""}
                let kd = configItems[index].value
                command = "\(CMD_SET_PID_COEFFICIENTS)\(newValue),\(ki),\(kd)"
                break
                
            case "ki:":
                guard let index = editItemIndex(prompt: "kp:") else {return ""}
                let kp = configItems[index].value
                guard let index = editItemIndex(prompt: "kd:") else {return ""}
                let kd = configItems[index].value
                command = "\(CMD_SET_PID_COEFFICIENTS)\(kp),\(newValue),\(kd)"
                break
                
            case "kd:":
                guard let index = editItemIndex(prompt: "kp:") else {return ""}
                let kp = configItems[index].value
                guard let index = editItemIndex(prompt: "ki:") else {return ""}
                let ki = configItems[index].value
                command = "\(CMD_SET_PID_COEFFICIENTS)\(kp),\(ki),\(newValue)"
                break
                
            case "Offset:":
                command = "\(CMD_SET_ACTUATOR_OFFSET)\(newValue)"
                break
                
            case "TargetHeading:":
                command = "\(CMD_SET_TARGET_HEADING)\(newValue)"
                break
                
            case "CompassCorrection:":
                command = "\(CMD_CAL_CURRENT_HEADING)\(newValue)"
                break
                
            case "Position:":
                command = "\(CMD_SET_ACTUATOR_POSITION)\(newValue)"
                break
                
            case "Null Zone:":
                command = "\(CMD_SET_MOVE_NULL_ZONE)\(newValue)"
                break
                
            case "limit Move:":
                command = "\(CMD_SET_ACTUATOR_LIMIT)\(newValue)"
                break
                
            case "CirclingSeconds:":
                guard let index = editItemIndex(prompt:"CirclingSegments:") else {return""}
                let segments = configItems[index].value
                command = "\(CMD_SET_CIRCLING_PARAMETERS)\(newValue),\(segments)"
                break
                
            case "CirclingSegments:":
                guard let index = editItemIndex(prompt:"CirclingSeconds:") else {return""}
                let seconds = configItems[index].value
                command = "\(CMD_SET_CIRCLING_PARAMETERS)\(seconds),\(newValue)"
                break
                
            case "CalInterval:":
                command = "\(CMD_SET_CAL_INTERVAL)\(newValue)"
                break
                
            case "PidInterval:":
                command = "\(CMD_SET_PID_INTERVAL)\(newValue)"
                break
                
            case "RecalWait:":
                command = "\(CMD_SET_RECAL_INTERVAL)\(newValue)"
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
        configItems.append(PV(prompt: "SensorCal(SGAM):", value: MySubString(src: configString, sub: "Cal=", returnLen: 6, offset: 4),editable:false))
        configItems.append(PV(prompt: "Offset:", value: String(Float(MySubString(src: configString, sub: "Offset=", returnLen: 6, offset: 7)) ?? 0),editable:true))
        configItems.append(PV(prompt: "Target:", value: String(Float(MySubString(src: configString, sub: "Target=", returnLen: 6, offset: 7)) ?? 0),editable:true))
        configItems.append(PV(prompt: "Heading:", value: String(Float(MySubString(src: configString, sub: "Heading=", returnLen: 6, offset: 8)) ?? 0),editable:false))
        configItems.append(PV(prompt: "Position:", value: String(Float(MySubString(src: configString, sub: "Position=", returnLen: 4, offset: 9)) ?? 0),editable:true))
        configItems.append(PV(prompt: "kp:", value: String(Float(MySubString(src: configString, sub: "kp=", returnLen: 5, offset: 3)) ?? 0),editable:true))
        configItems.append(PV(prompt: "ki:", value: String(Float(MySubString(src: configString, sub: "ki=", returnLen: 5, offset: 3)) ?? 0),editable:true))
        configItems.append(PV(prompt: "kd:", value: String(Float(MySubString(src: configString, sub: "kd=", returnLen: 5, offset: 3)) ?? 0),editable:true))
        configItems.append(PV(prompt: "Null Zone:", value: String(Float(MySubString(src: configString, sub: "Null Zone=", returnLen: 5, occurance: 1, offset: 10)) ?? 0),editable:true))
        configItems.append(PV(prompt: "limit Move:", value: String(Float(MySubString(src: configString, sub: "limit Move=", returnLen: 5, occurance: 1, offset: 11)) ?? 0),editable:true))
        configItems.append(PV(prompt: "CirclingSeconds:", value: String(Int(MySubString(src: configString, sub: "CirclingSeconds=", returnLen: 5, offset: 16)) ?? 0),editable:true))
        configItems.append(PV(prompt: "CirclingSegments:", value: String(Int(MySubString(src: configString, sub: "CirclingSegments=", returnLen: 5, offset: 17)) ?? 0),editable:true))
        configItems.append(PV(prompt: "PidInterval:", value: String(Int(MySubString(src: configString, sub: "PidInterval=", returnLen: 5, occurance: 1, offset: 12)) ?? 0),editable:true))
        configItems.append(PV(prompt: "RecalWait:", value: String(Int(MySubString(src: configString, sub: "RecalWait=", returnLen: 5, occurance: 1, offset: 10)) ?? 0),editable:true))
        configItems.append(PV(prompt: "CalInterval:", value: String(Int32(MySubString(src: configString, sub: "CalInterval=", returnLen: 8, occurance: 1, offset: 12)) ?? 0),editable:true))
        configItems.append(PV(prompt: "Drive(Prop/Incr):", value: MySubString(src: configString, sub: "Drive=", returnLen: 5, occurance: 1, offset: 6),editable:true))
        configItems.append(PV(prompt: "AlwaysRunLoop:", value: MySubString(src: configString, sub: "AlwaysRunLoop=", returnLen: 3, offset: 14),editable:true))
        for item in configItems{
            print("\(item)")
        }
        ble!.messageReceivedFromAPDelegate = nil
    }
}



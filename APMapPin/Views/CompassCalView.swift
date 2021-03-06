//
//  CompassCalView.swift
//  APMapPin
//
//  Created by Gary Hamann on 5/5/22.
//

import SwiftUI
import CoreLocation

protocol CompassCalLocationDelegate{
    func compassCalLocation(location:CLLocation)
}
protocol CompassCalHeadingDelegate{
    func compassCalHeading(heading:CLHeading)
}
protocol CompassCalAPMessageDelegate{
    func compassCalAPMessage(message:String)
}

struct CompassCalView: View{
    @EnvironmentObject var gvm:GlobalViewModel
    @EnvironmentObject var ble:BLEManager
    var settings:Settings = Settings()
    @State var headingString = ""
    @State var lastCalHeading = ""
    @State var locationString = ""
    @State var speedString = ""
    @State var courseString = ""
    @State var apTarget = ""
    @State var apHeading = ""
    @State var apCalState = ""
    @State var lastLocation:CLLocation?
    @State var lastHeading:CLHeading?
    @State var getHeadingTimer:Timer?
    @State var invalidCourse:Bool = true
    @State var msgCount:Int = 0
    @State var accel:String = ""
    @State var gyro:String = ""
    @State var mag:String = ""
    @State var accelRadius:String = ""
    @State var magRadius:String = ""
    @State var getCal:Bool = false
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text("Lat-Lon: \(locationString)")
                    Text("Speed: \(speedString)")
                    Text("Course: \(courseString)")
                    Text("Device Heading: \(headingString)")
                    Text("Last Cal Heading: \(lastCalHeading)")
                    Text("")
                    Text("AP Target: \(apTarget)")
                    Text("AP Heading: \(apHeading)")
                    Text("AP CalState(SGAM): \(apCalState)")
                    Text("Msg Count: \(msgCount)")
                }
                Spacer()
            }
            Spacer()
            Text("Cal with...")
            HStack{
                Button {SendHeadingToAP()} label: {Text("Device Heading")}
                    .buttonStyle(width: 150)
                Text("")
                Button {SendCourseToAP()} label: {Text("Course")}
                    .buttonStyle(width: 80, enable: !invalidCourse)
                
            }
            Spacer()
            HStack{
                
                VStack(alignment: .leading){
                    HStack{
                        Button {getCal = true} label: {Text("Get BNO Cal")}
                            .buttonStyle(width: 150)
                        Button {ble.sendMessageToAP(data: "\(CMD_CAL_USE_CURRENT_OFFSETS)")} label: {Text("Use this Cal")}
                            .buttonStyle(width: 150)
                    }
                    Text("")
                    Text("Accel: \(accel)")
                    Text("Gyro: \(gyro)")
                    Text("Mag: \(mag)")
                    Text("AccelRadius: \(accelRadius)")
                    Text("MagRadius: \(magRadius)")
                }
                Spacer()
            }
            .padding()
        }
        .padding()
        .onAppear {
            OnAppear()
        }
        .onDisappear {
            OnDisappear()
        }
    }
}

struct ButtonModifier: ViewModifier {
    var width:CGFloat
    var enable:Bool
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: 30)
            .background(enable ? .blue : .gray)
            .cornerRadius(10)
            .foregroundColor(.white)
            .disabled(!enable)
    }
}

extension View{
    func buttonStyle(width:CGFloat, enable:Bool = true) -> some View{
        modifier(ButtonModifier(width: width, enable: enable))
    }
}

extension CompassCalView: CompassCalLocationDelegate, CompassCalHeadingDelegate, CompassCalAPMessageDelegate{
    
    /*
     The getHeadingTimer periodically asks for heading every 2s
     after receiving the heading, I ask for the following sequentially...
     target heading
     last cal heading
     and if getCal is set, I ask for bno calibration offsets, but his is only once per button press
     */
    func compassCalAPMessage(message: String) {
        var temp = MySubString(src: message, sub: "Heading=", returnLen: 6, offset: 8)
        if temp.count > 0{
            apHeading = temp
            ble.sendMessageToAP(data: "\(CMD_GET_CURRENT_HEADING_TARGET)")
            msgCount += 1
            return
        }
        
        temp = MySubString(src: message, sub: "Target=", returnLen: 6, offset: 7)
        if temp.count > 0{
            if !settings.navigation.phoneHeadingMode{apTarget = temp}
            ble.sendMessageToAP(data: "\(CMD_GET_BNO_CAL_STATES)")
            return
        }
        
        temp = MySubString(src: message, sub: "Cal=", returnLen: 6, offset: 4)
        if temp.count > 0{
            apCalState = temp
            if (getCal){
                ble.sendMessageToAP(data: "\(CMD_GET_BNO_OFFSETS)")
                getCal = false;
            }
            return;
        }
        
        if message.contains("A: "){
            temp = MySubString(src: message, sub: "A: ", returnLen: 15, offset: 3)
            accel = temp
            temp = MySubString(src: message, sub: "G: ", returnLen: 15, offset: 3)
            gyro = temp
            temp = MySubString(src: message, sub: "M: ", returnLen: 15, offset: 3)
            mag = temp
            temp = MySubString(src: message, sub: "AR: ", returnLen: 15, offset: 4)
            accelRadius = temp
            temp = MySubString(src: message, sub: "MR: ", returnLen: 15, offset: 4)
            magRadius = temp
        }
    }
    
    func compassCalLocation(location: CLLocation) {
        lastLocation = location
        let coord = location.coordinate
        locationString = "\(String(format:"%.4f",coord.latitude)),\(String(format:"%.4f",coord.longitude))"
        speedString = "\(String(format: "%.2f", lastLocation!.speed))"
        invalidCourse=location.course == -1
        courseString = "\(String(format: "%.2f", location.course))"
    }
    
    func compassCalHeading(heading: CLHeading) {
        lastHeading = heading
        headingString = "\(String(format: "%.2f",heading.trueHeading))"
        if settings.navigation.phoneHeadingMode{apTarget = headingString}
    }
    
    func OnAppear(){
        gvm.compassCalLocationDelegate = self
        gvm.compassCalHeadingDelegate = self
        gvm.compassCalAPMessageDelegate = self
        msgCount = 0;
        getHeadingTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { Timer in
            self.GetHeadingFromAP()
        }
    }
    
    func OnDisappear(){
        gvm.compassCalHeadingDelegate = nil
        gvm.compassCalLocationDelegate = nil
        gvm.compassCalAPMessageDelegate = nil
        if let timer = getHeadingTimer{
            timer.invalidate()
        }
    }
    func SendHeadingToAP(){
        ble.sendMessageToAP(data: "\(CMD_CAL_CURRENT_HEADING)\(headingString)")
        gvm.apIsCalibrated = true
        lastCalHeading = headingString
    }
    func SendCourseToAP(){
        ble.sendMessageToAP(data: "\(CMD_CAL_CURRENT_HEADING)\(courseString)")
        gvm.apIsCalibrated = true
        lastCalHeading = courseString
    }
    func GetHeadingFromAP(){
        ble.sendMessageToAP(data: "\(CMD_GET_CURRENT_HEADING)")
    }
}
struct CompassCalView_Previews: PreviewProvider {
    static var previews: some View {
        CompassCalView()
            .environmentObject(GlobalViewModel())
            .environmentObject(BLEManager())
    }
}

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
    @State var accuracyString = ""
    @State var startLocationString = ""
    @State var totalDistanceString = ""
    @State var locationString = ""
    @State var sampleDistanceString = ""
    @State var altitudeString = ""
    @State var speedString = ""
    @State var courseString = ""
    @State var apTarget = ""
    @State var apHeading = ""
    @State var lastLocation:CLLocation?
    @State var lastHeading:CLHeading?
    @State var getHeadingTimer:Timer?
    @State var invalidCourse:Bool = true
    @State var msgCount:Int = 0
    @State var locationUpdateCount:Int = 0
    @State var startLocation:CLLocation?

    
//    @State var accel:String = ""
//    @State var gyro:String = ""
//    @State var mag:String = ""
//    @State var accelRadius:String = ""
//    @State var magRadius:String = ""
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Group{ // debug group
                        Text("UpdateCount: \(locationUpdateCount)")
                        Text("Accuracy:    \(accuracyString)")
                        Text("StartLoc:     \(startLocationString)")
                        Text("CurrentLoc:  \(locationString)")
                        Text("TotalDist:    \(totalDistanceString)")
                        Text("SampleDist:  \(sampleDistanceString)")
                    }
                    Group{
                        
                        
                        
                        Text("Speed: \(speedString)")
                    }
                    Group{
                        Text("Course: \(courseString)")
                        Text("Altitude: \(altitudeString)")
                        Text("Device Heading: \(headingString)")
                        Text("Last Cal Heading: \(lastCalHeading)")
                    }
                    Group{
                        Text("")
                        Text("AP Target: \(apTarget)")
                        Text("AP Heading: \(apHeading)")
                        Text("Msg Count: \(msgCount)")
                    }
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
            return
        }
    }
    
    func compassCalLocation(location: CLLocation) {
        if lastLocation == nil{
            lastLocation = location
            return
        }
        if startLocation == nil{
            startLocation = location
        }
        locationUpdateCount += 1
        let totalDistance = location.distance(from: startLocation!)
        totalDistanceString = "\(String(format:"%.4f",totalDistance * feetInMeters))"
        
        let sampleDistance = location.distance(from: lastLocation!)
        sampleDistanceString = "\(String(format:"%.4f",sampleDistance * feetInMeters))"
        
        altitudeString = "\(String(format:"%.1f",location.altitude * feetInMeters))"
        
        var coord = location.coordinate
        locationString = "\(String(format:"%.6f",coord.latitude)),\(String(format:"%.6f",coord.longitude))"
        
        coord = startLocation!.coordinate
        startLocationString = "\(String(format:"%.6f",coord.latitude)),\(String(format:"%.6f",coord.longitude))"
        
        accuracyString = "\(String(format: "%.1f", location.horizontalAccuracy))"
        
        speedString = "\(String(format: "%.2f", location.speed * mphInMetersPerSecond))"
        
        invalidCourse=location.course == -1 // used to enable/disable the course button
        courseString = invalidCourse ? "Invalid" : "\(String(format: "%.1f", location.course))"
        
        print(accuracyString,sampleDistanceString,totalDistanceString,altitudeString,locationString,speedString,courseString)
        lastLocation = location
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

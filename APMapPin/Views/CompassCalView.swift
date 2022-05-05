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
    @State var headingString = ""
    @State var lastCalHeading = ""
    @State var locationString = ""
    @State var courseString = ""
    @State var apTarget = ""
    @State var apHeading = ""
    @State var apCalState = ""
    @State var lastLocation:CLLocation?
    @State var lastHeading:CLHeading?
    @State var getHeadingTimer:Timer?
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text("Lat-Lon: \(locationString)")
                    Text("Course: \(courseString)")
                    Text("Device Heading: \(headingString)")
                    Text("Last Cal Heading: \(lastCalHeading)")
                    Text("")
                    Text("AP Target: \(apTarget)")
                    Text("AP Heading: \(apHeading)")
                    Text("AP CalState: \(apCalState)")
                }
                Spacer()
            }
            Spacer()
            Text("Cal with...")
            Button {SendHeadingToAP()} label: {Text("Device Heading")}
                .frame(width: 150, height: 30)
                .background(.blue)
                .cornerRadius(10)
                .foregroundColor(.white)
            Text("")
            Button {SendCourseToAP()} label: {Text("Course")}
                .frame(width: 150, height: 30)
                .background(.blue)
                .cornerRadius(10)
                .foregroundColor(.white)
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

extension CompassCalView: CompassCalLocationDelegate, CompassCalHeadingDelegate, CompassCalAPMessageDelegate{
    func compassCalAPMessage(message: String) {
        var temp = MySubString(src: message, sub: "Heading=", returnLen: 6, offset: 8)
        if temp.count > 0{
            apHeading = temp
            ble.sendMessageToAP(data: "gt")
            return
        }
        
        temp = MySubString(src: message, sub: "Target=", returnLen: 6, offset: 7)
        if temp.count > 0{
            apTarget = temp
            ble.sendMessageToAP(data: "gc")
            return
        }
        
        temp = MySubString(src: message, sub: "Cal=", returnLen: 6, offset: 4)
        if temp.count > 0{apCalState = temp}
    }
    
    func compassCalLocation(location: CLLocation) {
        lastLocation = location
        let coord = location.coordinate
        locationString = "\(String(format:"%.4f",coord.latitude)),\(String(format:"%.4f",coord.longitude))"
        courseString = "\(String(format: "%.2f", location.course))"
    }
    
    func compassCalHeading(heading: CLHeading) {
        lastHeading = heading
        headingString = "\(String(format: "%.2f",heading.trueHeading))"
    }
    
    func OnAppear(){
        gvm.compassCalLocationDelegate = self
        gvm.compassCalHeadingDelegate = self
        gvm.compassCalAPMessageDelegate = self
        getHeadingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { Timer in
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
        ble.sendMessageToAP(data: "hc\(headingString)")
        gvm.apIsCalibrated = true
        lastCalHeading = headingString
    }
    func SendCourseToAP(){
        ble.sendMessageToAP(data: "hc\(courseString)")
        gvm.apIsCalibrated = true
        lastCalHeading = courseString
    }
    func GetHeadingFromAP(){
        ble.sendMessageToAP(data: "gh")
    }
}
struct CompassCalView_Previews: PreviewProvider {
    static var previews: some View {
        CompassCalView()
            .environmentObject(GlobalViewModel())
            .environmentObject(BLEManager())
    }
}

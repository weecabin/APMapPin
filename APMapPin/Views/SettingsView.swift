//
//  SettingsView.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/10/22.
//

import SwiftUI



struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var gvm:GlobalViewModel
    @State var settings:Settings = Settings()
    @State var crumbInterval:String = ""
    @State var crumbDistance:String = ""
    @State var navArrivalZone:String = ""
    
    @State var navInterval:String = ""
    @State var navProportional:String = ""
    @State var navTimerMode:String = "false"
    @State var navMaxCorrection:String = ""
    
    @State var simSpeed:String = ""
    @State var simEnabled:String = "false"
    @State var simWindPercent:String = ""
    
    @State var mapTrackLocation:String = "false"
    
    var body: some View {
        VStack{
            VStack(alignment:.leading){
                Text("Bread Crumbs")
                HStack{
                    VStack(alignment: .trailing){
                        Text("Interval(s):")
                            .frame(height: 20)
                        Text("Min Distance(ft):")
                            .frame(height: 20)
                    }
                    .padding(0)
                    .frame(width: 180)
                    
                    VStack(alignment: .leading){
                        TextField("interval", text: $crumbInterval)
                            .frame(height: 20)
                        TextField("distance", text: $crumbDistance)
                            .frame(height: 20)
                    }
                    .padding(0)
                }
            }
            
            VStack(alignment:.leading){
                Divider()
                Text("Navigation")
                HStack{
                    VStack(alignment: .trailing){
                        Text("TimerMode:")
                            .frame(height: 20)
                        Text("interval(s):")
                            .frame(height: 20)
                        Text("ArrivalZone(ft):")
                            .frame(height: 20)
                        Text("PID-kp:")
                            .frame(height: 20)
                        Text("MaxCorrection:")
                            .frame(height: 20)
                    }
                    .frame(width: 180)
                    
                    VStack(alignment: .leading){
                        timerModeView
                            .frame(height: 20)
                        TextField("interval", text: $navInterval)
                            .frame(height: 20)
                        TextField("arrivalZone", text: $navArrivalZone)
                            .frame(height: 20)
                        TextField("PID-kp", text: $navProportional)
                            .frame(height: 20)
                        TextField("maxCorrection", text: $navMaxCorrection)
                            .frame(height: 20)
                    }
                }
            }
            
            VStack(alignment:.leading){
                Divider()
                Text("Simulator")
                HStack{
                    VStack(alignment:.trailing){
                        Text("Simulate:")
                            .frame(height: 20)
                        Text("Speed(mph):")
                            .frame(height: 20)
                        Text("WindPercent:")
                            .frame(height: 20)
                    }
                    .frame(width:180)
                    
                    VStack(alignment: .leading){
                        enableSimView
                            .frame(height: 20)
                        TextField("Speed", text: $simSpeed)
                            .frame(height: 20)
                        TextField("WindPercent", text: $simWindPercent)
                            .frame(height: 20)
                    }
                }
            }
            
            VStack(alignment:.leading){
                Divider()
                Text("Map Settings")
                HStack{
                    VStack(alignment:.trailing){
                        Text("TrackLocation:")
                            .frame(height: 20)
                    }
                    .frame(width:180)
                    
                    VStack(alignment: .leading){
                        trackLocationView
                            .frame(height: 20)
                    }
                }
            }
            
            VStack{
                Divider()
                HStack{
                    Spacer()
                    Button("OK"){saveSettings()}
                        .frame(width: 80, height: 30)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    Spacer()
                    Button("Cancel"){presentationMode.wrappedValue.dismiss()}
                        .frame(width: 80, height: 30)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .padding()
        .onAppear {
            initView()
        }
    }
    
    var trackLocationView:some View{
        HStack{
            Button {
                if mapTrackLocation=="false"{
                    mapTrackLocation = "true"
                }else{
                    mapTrackLocation = "false"
                }
            } label: {
                Text(mapTrackLocation)
            }
        }
    }
    
    var timerModeView:some View{
        HStack{
            Button {
                if navTimerMode=="false"{
                    navTimerMode = "true"
                }else{
                    navTimerMode = "false"
                }
            } label: {
                Text(navTimerMode)
            }
        }
    }
    
    var enableSimView:some View{
        HStack{
            Button {
                if simEnabled=="false"{
                    simEnabled = "true"
                }else{
                    simEnabled = "false"
                }
            } label: {
                Text(simEnabled)
            }
        }
    }
    
    func initView(){
        crumbDistance = String(settings.breadCrumbs.minSeparationFeet)
        crumbInterval = String(settings.breadCrumbs.intervalSeconds)
        
        navInterval = String(settings.navigation.intervalSeconds)
        navArrivalZone = String(settings.navigation.arrivalZoneFeet)
        navProportional = String(settings.navigation.proportionalTerm)
        navTimerMode = settings.navigation.timerMode ? "true" : "false"
        navMaxCorrection = String(settings.navigation.maxCorrectionDeg)
        
        simSpeed = String(settings.simulator.speed)
        simEnabled = settings.simulator.enabled ? "true" : "false"
        simWindPercent = String(settings.simulator.windPercent)
        
        mapTrackLocation = settings.map.trackLocation ? "true" : "false"
    }
    
    func saveSettings(){
        settings.breadCrumbs.intervalSeconds = Double(crumbInterval) ?? settings.breadCrumbs.defaultInterval
        settings.breadCrumbs.minSeparationFeet = Double(crumbDistance) ?? settings.breadCrumbs.defaultSeparation
        
        settings.navigation.arrivalZoneFeet = Double(navArrivalZone) ?? settings.navigation.defaultArrivalZone
        settings.navigation.intervalSeconds = Double(navInterval) ?? settings.navigation.defaultInterval
        settings.navigation.proportionalTerm = Double(navProportional) ?? settings.navigation.defaultProportionalTerm
        settings.navigation.timerMode = navTimerMode == "true"
        settings.navigation.maxCorrectionDeg = Double(navMaxCorrection) ?? settings.navigation.defaultMaxCorrection
        
        settings.simulator.speed = Double(simSpeed) ?? settings.simulator.defaultSimSpeed
        let prevSimMode = settings.simulator.enabled
        settings.simulator.enabled = simEnabled == "true"
        if prevSimMode == true && settings.simulator.enabled == false{
            gvm.apIsCalibrated = false
        }
        settings.simulator.windPercent = Double(simWindPercent) ?? settings.simulator.defaultWindPercent
        
        
        presentationMode.wrappedValue.dismiss()
        
        settings.map.trackLocation = mapTrackLocation == "true"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

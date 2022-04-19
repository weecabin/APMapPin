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
    @State var navSimulatedSpeed:String = ""
    @State var navEnableSimulation:String = "false"
    @State var navTimerMode:String = "false"
    
    @State var mapTrackLocation:String = "false"
    
    var body: some View {
        VStack(alignment: .leading){
            Text("BreadCrumbs")
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
                    Text("Simulate:")
                        .frame(height: 20)
                    Text("SimSpeed(mph):")
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
                    enableSimView
                        .frame(height: 20)
                    TextField("NavSimSpeed", text: $navSimulatedSpeed)
                        .frame(height: 20)
                }
            }
            Divider()
            Text("Map Settings")
            HStack{
                VStack(alignment: .trailing){
                    Text("TrackLocation:")
                        .frame(height: 20)
                }
                VStack(alignment: .leading){
                    trackLocationView
                        .frame(height: 20)
                }
            }
            .frame(width: 180)
            
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
                if navEnableSimulation=="false"{
                    navEnableSimulation = "true"
                }else{
                    navEnableSimulation = "false"
                }
            } label: {
                Text(navEnableSimulation)
            }
        }
    }
    
    func initView(){
        crumbDistance = String(settings.breadCrumbs.minSeparationFeet)
        crumbInterval = String(settings.breadCrumbs.intervalSeconds)
        
        navInterval = String(settings.navigation.intervalSeconds)
        navArrivalZone = String(settings.navigation.arrivalZoneFeet)
        navProportional = String(settings.navigation.proportionalTerm)
        navSimulatedSpeed = String(settings.navigation.simulatedSpeed)
        navEnableSimulation = settings.navigation.enableSimulation ? "true" : "false"
        navTimerMode = settings.navigation.timerMode ? "true" : "false"
        
        mapTrackLocation = settings.map.trackLocation ? "true" : "false"
    }
    
    func saveSettings(){
        settings.breadCrumbs.intervalSeconds = Double(crumbInterval) ?? settings.breadCrumbs.defaultInterval
        settings.breadCrumbs.minSeparationFeet = Double(crumbDistance) ?? settings.breadCrumbs.defaultSeparation
        
        settings.navigation.arrivalZoneFeet = Double(navArrivalZone) ?? settings.navigation.defaultArrivalZone
        settings.navigation.intervalSeconds = Double(navInterval) ?? settings.navigation.defaultInterval
        settings.navigation.proportionalTerm = Double(navProportional) ?? settings.navigation.defaultProportionalTerm
        settings.navigation.simulatedSpeed = Double(navSimulatedSpeed) ?? settings.navigation.defaultSimulatedSpeed
        let prevSimMode = settings.navigation.enableSimulation
        settings.navigation.enableSimulation = navEnableSimulation == "true"
        if prevSimMode == true && settings.navigation.enableSimulation == false{
            gvm.apIsCalibrated = false
        }
        settings.navigation.timerMode = navTimerMode == "true"
        presentationMode.wrappedValue.dismiss()
        
        settings.map.trackLocation = mapTrackLocation == "true"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

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
    @State var navIntegral:String = ""
    @State var navDifferential:String = ""
    @State var navPidLength:String = ""
    @State var navTimerMode:String = "false"
    @State var navMaxCorrection:String = ""
    @State var navPhoneHeadingMode:String = "false"
    @State var navLoopRoute:String = "false"
    
    @State var simSpeed:String = ""
    @State var simEnabled:String = "false"
    @State var simWindPercent:String = ""
    @State var simTurnRate:String = ""
    
    @State var mapTrackLocation:String = "false"
    
    let elementNameWidth:CGFloat = 200
    
    var body: some View {
        VStack{
            ScrollView{
                dividerView
                mapView
                dividerView
                navigationView
                dividerView
                breadCrumbView
                dividerView
                simulatorView
                dividerView
            }
            actionView
        }
        .padding()
        .onAppear {
            initView()
        }
    }

    var dividerView:some View{
        Rectangle()
            .fill(Color.black)
            .frame(height: 5)
            .edgesIgnoringSafeArea(.horizontal)
    }
    
    var navigationView:some View{
        VStack(alignment:.leading){
            HStack{
                Spacer()
                Text("Navigation")
                    .font(.title2)
                Spacer()
            }
            HStack{
                VStack(alignment: .trailing){
                    Text("Loop Route:")
                        .frame(height: 20)
                    Text("Phone Mode:")
                        .frame(height: 20)
                    Text("Timer Mode:")
                        .frame(height: 20)
                    Text("interval(s):")
                        .frame(height: 20)
                    Text("Arrival Zone(ft):")
                        .frame(height: 20)
                    Text("PID-kp:")
                        .frame(height: 20)
                    Text("PID-ki:")
                        .frame(height: 20)
                    Text("PID-kd:")
                        .frame(height: 20)
                    Text("PID Length:")
                        .frame(height: 20)
                    Text("Max Err(deg):")
                        .frame(height: 20)
                }
                .frame(width: elementNameWidth)
                
                VStack(alignment: .leading){
                    navLoopRouteView
                    phoneHeadingModeView
                    timerModeView
                        .frame(height: 20)
                    TextField("interval", text: $navInterval)
                        .frame(height: 20)
                    TextField("arrivalZone", text: $navArrivalZone)
                        .frame(height: 20)
                    TextField("PID-kp", text: $navProportional)
                        .frame(height: 20)
                    TextField("PID-kp", text: $navIntegral)
                        .frame(height: 20)
                    TextField("PID-kp", text: $navDifferential)
                        .frame(height: 20)
                    TextField("PID Length", text: $navPidLength)
                        .frame(height: 20)
                    TextField("maxCorrection", text: $navMaxCorrection)
                        .frame(height: 20)
                }
                Spacer()
            }
        }
        .padding(0)
    }
    
    var mapView:some View{
        VStack(alignment: .leading){
            HStack{
                Spacer()
                Text("Map")
                    .font(.title2)
                Spacer()
            }
            .frame(width: elementNameWidth)
            
            HStack{
                VStack(alignment:.trailing){
                    Text("Track Location:")
                        .frame(height: 20)
                }
                .frame(width:180)
                
                VStack(alignment: .leading){
                    trackLocationView
                        .frame(height: 20)
                }
                Spacer()
            }
        }
    }
    
    var trackLocationView:some View{
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
    
    var simulatorView:some View{
        VStack(alignment:.leading){
            HStack{
                Spacer()
                Text("Simulator")
                    .font(.title2)
                Spacer()
            }
            HStack{
                VStack(alignment:.trailing){
                    Text("Enabled:")
                        .frame(height: 20)
                    Text("TurnRate:")
                        .frame(height: 20)
                    Text("Speed(mph):")
                        .frame(height: 20)
                    Text("Wind Percent:")
                        .frame(height: 20)
                }
                .frame(width: elementNameWidth)
                
                VStack(alignment: .leading){
                    enableSimView
                        .frame(height: 20)
                    TextField("TurnRate", text: $simTurnRate)
                        .frame(height: 20)
                    TextField("Speed", text: $simSpeed)
                        .frame(height: 20)
                    TextField("Wind Percent", text: $simWindPercent)
                        .frame(height: 20)
                }
                Spacer()
            }
        }
    }
    
    var breadCrumbView:some View{
        VStack(alignment:.leading){
            HStack{
                Spacer()
                Text("Bread Crumbs")
                    .font(.title2)
                Spacer()
            }
            HStack{
                VStack(alignment: .trailing){
                    Text("Interval(s):")
                        .frame(height: 20)
                    Text("Min Distance(ft):")
                        .frame(height: 20)
                }
                .frame(width: elementNameWidth)
                
                VStack(alignment: .leading){
                    TextField("interval", text: $crumbInterval)
                        .frame(height: 20)
                    TextField("distance", text: $crumbDistance)
                        .frame(height: 20)
                }
                Spacer()
            }
        }
    }
    
    var actionView:some View{
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
    var navLoopRouteView:some View{
        HStack{
            Button {
                if navLoopRoute=="false"{
                    navLoopRoute = "true"
                }else{
                    navLoopRoute = "false"
                }
            } label: {
                Text(navLoopRoute)
            }
        }
    }
    
    var phoneHeadingModeView:some View{
        HStack{
            Button {
                if navPhoneHeadingMode=="false"{
                    navPhoneHeadingMode = "true"
                }else{
                    navPhoneHeadingMode = "false"
                }
            } label: {
                Text(navPhoneHeadingMode)
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
        navIntegral = String(settings.navigation.integralTerm)
        navDifferential = String(settings.navigation.differentialTerm)
        navPidLength = String(settings.navigation.pidLength)
        navTimerMode = settings.navigation.timerMode ? "true" : "false"
        navMaxCorrection = String(settings.navigation.maxCorrectionDeg)
        navPhoneHeadingMode = settings.navigation.phoneHeadingMode ? "true" : "false"
        navLoopRoute = settings.navigation.loopRoute ? "true" : "false"
        
        simSpeed = String(settings.simulator.speed)
        simEnabled = settings.simulator.enabled ? "true" : "false"
        simWindPercent = String(settings.simulator.windPercent)
        simTurnRate = String(settings.simulator.turnRate)
        
        mapTrackLocation = settings.map.trackLocation ? "true" : "false"
    }
    
    func saveSettings(){
        settings.breadCrumbs.intervalSeconds = Double(crumbInterval) ?? settings.breadCrumbs.defaultInterval
        settings.breadCrumbs.minSeparationFeet = Double(crumbDistance) ?? settings.breadCrumbs.defaultSeparation
        
        settings.navigation.arrivalZoneFeet = Double(navArrivalZone) ?? settings.navigation.defaultArrivalZone
        settings.navigation.intervalSeconds = Double(navInterval) ?? settings.navigation.defaultInterval
        settings.navigation.proportionalTerm = Double(navProportional) ?? settings.navigation.defaultProportionalTerm
        settings.navigation.integralTerm = Double(navIntegral) ?? settings.navigation.defaultIntegralTerm
        settings.navigation.differentialTerm = Double(navDifferential) ?? settings.navigation.defaultDiffernetialTerm
        settings.navigation.pidLength = Int(navPidLength) ?? settings.navigation.defaultPidLength
        settings.navigation.timerMode = navTimerMode == "true"
        settings.navigation.maxCorrectionDeg = Double(navMaxCorrection) ?? settings.navigation.defaultMaxCorrection
        settings.navigation.phoneHeadingMode = navPhoneHeadingMode == "true"
        settings.navigation.loopRoute = navLoopRoute == "true"
        
        settings.simulator.speed = Double(simSpeed) ?? settings.simulator.defaultSimSpeed
        let prevSimMode = settings.simulator.enabled
        settings.simulator.enabled = simEnabled == "true"
        if prevSimMode == true && settings.simulator.enabled == false{
            gvm.apIsCalibrated = false
        }
        settings.simulator.windPercent = Double(simWindPercent) ?? settings.simulator.defaultWindPercent
        settings.simulator.turnRate = Double(simTurnRate) ?? settings.simulator.defaultTurnRate
        
        
        presentationMode.wrappedValue.dismiss()
        
        settings.map.trackLocation = mapTrackLocation == "true"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(GlobalViewModel())
    }
}

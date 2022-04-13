//
//  SettingsView.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/10/22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var settings:Settings = Settings()
    @State var crumbInterval:String = ""
    @State var crumbDistance:String = ""
    @State var navArrivalZone:String = ""
    @State var navInterval:String = ""
    @State var navProportional:String = ""
    @State var navSimulatedSpeed:String = ""
    
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
                    Text("interval(s):")
                        .frame(height: 20)
                    Text("ArrivalZone(ft):")
                        .frame(height: 20)
                    Text("PID-kp:")
                        .frame(height: 20)
                    Text("SimSpeed(mph)")
                        .frame(height: 20)
                }
                .frame(width: 180)
                
                VStack(alignment: .leading){
                    TextField("interval", text: $navInterval)
                        .frame(height: 20)
                    TextField("arrivalZone", text: $navArrivalZone)
                        .frame(height: 20)
                    TextField("PID-kp", text: $navProportional)
                        .frame(height: 20)
                    TextField("NavSimSpeed", text: $navSimulatedSpeed)
                        .frame(height: 20)
                }
            }
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
            
            Spacer()
        }
        .padding()
        .onAppear {
            initView()
        }
    }
    
    func initView(){
        crumbDistance = String(settings.breadCrumbs.minSeparationFeet)
        crumbInterval = String(settings.breadCrumbs.intervalSeconds)
        navInterval = String(settings.navigation.intervalSeconds)
        navArrivalZone = String(settings.navigation.arrivalZoneFeet)
        navProportional = String(settings.navigation.proportionalTerm)
        navSimulatedSpeed = String(settings.navigation.simulatedSpeed)
    }
    
    func saveSettings(){
        settings.navigation.arrivalZoneFeet = Double(navArrivalZone) ?? settings.navigation.defaultArrivalZone
        settings.navigation.intervalSeconds = Double(navInterval) ?? settings.navigation.defaultInterval
        settings.breadCrumbs.intervalSeconds = Double(crumbInterval) ?? settings.breadCrumbs.defaultInterval
        settings.breadCrumbs.minSeparationFeet = Double(crumbDistance) ?? settings.breadCrumbs.defaultSeparation
        settings.navigation.proportionalTerm = Double(navProportional) ?? settings.navigation.defaultProportionalTerm
        settings.navigation.simulatedSpeed = Double(navSimulatedSpeed) ?? settings.navigation.defaultSimulatedSpeed
        presentationMode.wrappedValue.dismiss()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

//
//  SetHeadingView.swift
//  APWatchApp WatchKit Extension
//
//  Created by Gary Hamann on 4/28/22.
//

import SwiftUI
protocol HeadingAvailableDelegate{
    func newHeading(heading:CLHeading)
}

struct SetHeadingView: View{
    
    
    @EnvironmentObject var vm:ViewModel
    @State var trueHeading:String = "?"
    var body: some View {
        VStack{
            Button {
                vm.SendMessage(msg: "\(CMD_CAL_CURRENT_HEADING)\(trueHeading)")
            } label: {
                Text("Cal heading")
                    .frame(width: 120, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            Text(trueHeading)
                .font(.largeTitle)
            Button {
                vm.SendMessage(msg: "\(CMD_SET_TARGET_HEADING)\(trueHeading)")
            } label: {
                Text("Set heading")
                    .frame(width: 120, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            
        }
        .onAppear {
            vm.locationManager.startUpdatingHeading()
            vm.headingAvailableDelegate = self
        }
        .onDisappear {
            vm.locationManager.stopUpdatingHeading()
            vm.headingAvailableDelegate = nil
        }
        
    }
}

extension SetHeadingView: HeadingAvailableDelegate{
    func newHeading(heading: CLHeading) {
        trueHeading = String(format: "%.1f", heading.trueHeading)
    }
}

struct SetHeadingView_Previews: PreviewProvider {
    static var previews: some View {
        SetHeadingView()
            .environmentObject(ViewModel())
    }
}

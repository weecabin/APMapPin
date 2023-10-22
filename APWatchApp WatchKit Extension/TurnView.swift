//
//  TurnView.swift
//  APWatchApp WatchKit Extension
//
//  Created by Gary Hamann on 4/12/22.
//

import SwiftUI
import WatchConnectivity

struct TurnView: View {
    @EnvironmentObject var vm:ViewModel
    @State var turnAngles:[Int] = [5,10,15,20,30,40,50,60,70,80,90]
    @State var turnAngle:Int = 5
    var body: some View {
        VStack(spacing: 0){
            Button {
                vm.Lock()
            } label: {
                Text("Lock")
                    .frame(width: vm.bw, height: vm.bh)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            //Spacer()
            HStack{
                Button {
                    vm.Left(delta: 10)
                } label: {
                    Text("L10")
                        .frame(width: vm.bw, height: vm.bh)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                Button {
                    vm.Right(delta: 10)
                } label: {
                    Text("R10")
                        .frame(width: vm.bw, height: vm.bh)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
            HStack{
                Button {
                    vm.Left(delta: turnAngle)
                } label: {
                    Text("L")
                        .frame(width: vm.bw, height: vm.bh)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                Picker("Angle", selection: $turnAngle) {
                    ForEach(turnAngles, id: \.self){
                        Text("\($0)")
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 40, height:50)
                Button {
                    vm.Right(delta: turnAngle)
                } label: {
                    Text("R")
                        .frame(width: vm.bw, height: vm.bh)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
        }
        .background(vm.backColor)
        .cornerRadius(10)
        .onAppear {
            vm.onTurnViewAppear()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TurnView()
            .environmentObject(ViewModel())
    }
}

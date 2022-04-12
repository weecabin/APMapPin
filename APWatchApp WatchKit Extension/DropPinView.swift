//
//  DropPinView.swift
//  APWatchApp WatchKit Extension
//
//  Created by Gary Hamann on 4/12/22.
//


import SwiftUI

struct DropPinView: View {
    @EnvironmentObject var vm:ViewModel
    let bh:CGFloat = 30
    let bw:CGFloat = 80
    var body: some View {
        VStack{
            Button {
                vm.SendMessage(msgType: .MapMsg, msg: "FishOn")
            } label: {
                Text("Fish On")
                    .frame(width: bw, height: bh)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            Button {
                vm.SendMessage(msgType: .MapMsg, msg: "Shallow")
            } label: {
                Text("Shallow")
                    .frame(width: bw, height: bh)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
    }
}

struct DropPinView_Previews: PreviewProvider {
    static var previews: some View {
        DropPinView()
            .environmentObject(ViewModel())
    }
}

//
//  CircleView.swift
//  APWatchApp WatchKit Extension
//
//  Created by Gary Hamann on 4/12/22.
//

import SwiftUI

struct CircleView: View {
    @EnvironmentObject var vm:ViewModel
    let bh:CGFloat = 30
    let bw:CGFloat = 50
    var body: some View {
        VStack{
            Text("Circling")
                .font(.headline)
            HStack{
                Spacer()
                Button {
                    vm.SendMessage(msg: "!B10")
                }label: {
                    Image("CircleLeft")
                        .resizable()
                        .frame(width: bh, height: bh)
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                }
                .frame(width: 50, height: 50)
                .cornerRadius(25)
                .buttonStyle(BorderedButtonStyle(tint: Color.blue.opacity(100)))
                Spacer()
                Button {
                    vm.SendMessage(msg: "!B20")
                } label: {
                    Image("CircleRight")
                        .resizable()
                        .frame(width: bh, height: bh)
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                }
                .frame(width: 50, height: 50)
                .buttonStyle(BorderedButtonStyle(tint: Color.blue.opacity(100)))
                Spacer()
            }
        }
    }
}

struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView()
            .environmentObject(ViewModel())
    }
}

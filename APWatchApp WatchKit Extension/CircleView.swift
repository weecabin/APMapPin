//
//  CircleView.swift
//  APWatchApp WatchKit Extension
//
//  Created by Gary Hamann on 4/12/22.
//

import SwiftUI

struct CircleView: View {
    @EnvironmentObject var vm:ViewModel
    @State var circleMinutes:[Int] = [3,4,5,6,7,8,9,10]
    @State var circleTimeInMinutes:Int = 6
    let bh:CGFloat = 30
    let bw:CGFloat = 50
    var body: some View {
        VStack{
            Text("Circling")
                .font(.headline)
            HStack{
                Spacer()
                Button {
                    vm.SendMessage(msg: "\(CMD_CIRCLE_LEFT)")
                    circleTimeInMinutes = 6
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
                    vm.SendMessage(msg: "\(CMD_CIRCLE_RIGHT)")
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
            HStack(alignment:.center){
                Spacer()
                Picker("mins", selection: $circleTimeInMinutes) {
                    ForEach(circleMinutes, id: \.self){
                        Text("\($0)")
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 40, height:50)
                VStack{
                    Text("")
                    Button {
                        vm.SendMessage(msg: "\(CMD_SET_CIRCLING_PARAMETERS)\(circleTimeInMinutes*60),36")
                    } label: {
                        Text("Set")
                            .frame(width: vm.bw, height: vm.bh)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }

            }.padding()
        }
        .background(vm.backColor)
        .cornerRadius(10)
    }
}

struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView()
            .environmentObject(ViewModel())
    }
}

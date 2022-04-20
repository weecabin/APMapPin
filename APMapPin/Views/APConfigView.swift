//
//  APConfigView.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/12/22.
//

import SwiftUI

struct APConfigView: View{
    
    // Playing around with text
    @State var phtext = "Sending: "
    @EnvironmentObject var ble: BLEManager
    @EnvironmentObject var apvm:ApConfigViewModel
    @EnvironmentObject var gvm:GlobalViewModel
    
    @State var editValue:String = ""
    
    var body: some View {
        ZStack{
            VStack {
                if gvm.navType != .none {cancelRouteView}
                Button {
                    apvm.toggleActuatorEnabled()
                } label: {
                    Text(apvm.actuatorEnabled ? "Disable Actuator" : "Enable Actuator")
                        .foregroundColor(apvm.actuatorEnabled ? .red : .green)
                }

                headingButtons
                Text(phtext)
                stateView
                Spacer()
            }
            VStack{
                if apvm.editItemId != nil {
                    editConfigItem
                }
                Spacer()
            }
        }
        .onAppear(perform: {
            apvm.onAppear(ble: ble)
        })
        .navigationTitle("AP")
        .navigationBarItems(trailing:NavigationLink("Map",destination: MapView()))
    }
}

extension APConfigView{
    private var cancelRouteView: some View{
        HStack{
            Text("Following Route...")
            Button {
                gvm.stopNavigation()
            } label: {
                Text("Cancel")
                    .frame(height: 40)
                    .padding(.horizontal, 10)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    private var stateView: some View{
        VStack{
            Button(action: {
                ble.messageReceivedFromAPDelegate = self
                ble.sendMessageToAP(data: "?c")
            }, label: {
                Text("Update State")
            })
                .frame(width: 150, height: 40, alignment: .center)
                .background((ble.connectedToAp ? Color.green : Color.gray) .cornerRadius(10))
                .foregroundColor(ble.connectedToAp ? .black : .white)
                .disabled(ble.connectedToAp ? false : true)
            List(apvm.configItems) { item in
                HStack{
                    Text(item.prompt)
                        .frame(width: 175, alignment:.trailing)
                    Text(item.value)
                        .frame(width:100)
                    if item.editable {
                    Button {
                        apvm.editItemId = item.id
                        editValue = apvm.editItemValue() ?? ""
                    } label: {
                        Image(systemName: "pencil")
                            .frame(width: 30, height: 30)
                            .background(Color.blue)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }

    private var editConfigItem: some View{
        VStack{
            Spacer()
            HStack{
                Text(apvm.editItemPrompt())
                TextField("value", text: $editValue)
                    .frame(width: 75)
                    .background(Color.white)
                    .foregroundColor(.black)
            }
            Spacer()
            HStack{
                Spacer()
                Button {
                    print("editValue = \(editValue)")
                    let command = apvm.configCommand(newValue: editValue)
                    print(command)
                    ble.sendMessageToAP(data: command)
                    if apvm.editItemPrompt() == "Heading"{
                        gvm.apIsCalibrated = true
                    }
                    apvm.editItemId = nil
                } label: {
                    Text("Submit")
                }
                .frame(width: 80, height: 30)
                .padding(5)
                .background(Color.blue)
                .cornerRadius(10)
                .foregroundColor(Color.black)
                Spacer()
                Button {
                    apvm.editItemId = nil
                } label: {
                    Text("Cancel")
                        .foregroundColor(Color.black)
                }
                .frame(width: 80, height: 30)
                .padding(5)
                .background(Color.blue)
                .cornerRadius(10)
                .foregroundColor(Color.black)
                Spacer()
            }
            Spacer()
        }
        .frame(width: 300, height: 100)
        .background(Color.gray)
        .cornerRadius(10)
    }
    
    private var headingButtons: some View{
        Group{
            HStack
            {
                HeadingButton(title: "Left 10", command:"h-10")
                HeadingButton(title: "Lock", command:"!B507", height: 30, width:60)
                HeadingButton(title: "Right 10", command:"h10")
            }
            .padding(5)
            
            HStack
            {
                HeadingButton(title: "Left 90", command:"h-90")
                HeadingButton(title: "Right 90", command:"h90")
            }
            .padding(5)
            HStack
            {
                HeadingButton(title: "Circle L", command:"!B10")
                //HeadingButton(title: "180")
                HeadingButton(title: "Circle R", command:"!B20")
            }
            .padding(5)
        }
    }
    
    func HeadingButton(title:String, command:String="", height:CGFloat = 30, width:CGFloat? = nil) -> some View {
        return Button(title) {
            var cmd = ""
            switch title{
            case "Left 10":
                cmd = "hi-10"
                break
            case "Right 10":
                cmd = "hi10"
                break
            case "Left 90":
                cmd = "hi-90"
                break
            case "Right 90":
                cmd = "hi90"
                break
            case "Lock","Circle L","Circle R":
                cmd = command
                break
            default:
                break
            }
            if cmd.count > 0{
                ble.sendMessageToAP(data: cmd)
                phtext = "Sending \(cmd)"
            }
        }
        .frame(width: width, height: height)
        .padding(10)
        .background((ble.connectedToAp && gvm.navType == .none && apvm.actuatorEnabled ? Color.green : Color.gray) .cornerRadius(height/2))
        .foregroundColor(ble.connectedToAp && gvm.navType == .none ? .black : .white)
        .disabled((ble.connectedToAp && gvm.navType == .none && apvm.actuatorEnabled) ? false : true)
    }
}

extension APConfigView: ReceiveApMessageDelegate{
    func messageIn(message: String) {
        print("In MessageInDelegate")
        apvm.updateConfigItems(configString: message)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView{
                APConfigView()
                    .environmentObject(BLEManager())
                    .environmentObject(ApConfigViewModel())
                    .environmentObject(GlobalViewModel())
                    .environmentObject(MapViewModel())
            }
            .navigationViewStyle(.stack)
        }
    }
}

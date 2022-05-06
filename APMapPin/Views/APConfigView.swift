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
    @State var writeEE:Bool = false
    let buttonHeight:CGFloat = 30
    let buttonWidth:CGFloat = 60
    
    
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
        .onDisappear(perform: {
            
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
            HStack{
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
                
                Button {
                    writeEE = true;
                } label: {
                    Text("Write EEProm")
                }
                .frame(width: 150, height: 40, alignment: .center)
                .background((ble.connectedToAp ? Color.green : Color.gray) .cornerRadius(10))
                .foregroundColor(ble.connectedToAp ? .black : .white)
                .disabled(ble.connectedToAp ? false : true)
                .alert(isPresented: $writeEE) {
                    Alert(title: Text("Write EEProm?"),
                          primaryButton:.default(Text("OK"),action: {ble.sendMessageToAP(data: "w")}),
                          secondaryButton:.cancel())}
            }

            
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
                    ble.messageReceivedFromAPDelegate = self
                    ble.sendMessageToAP(data: "?c")
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
            HStack{
                HeadingButton(title: "Lock", command:"!B507", height: buttonHeight, width:buttonWidth)
            }
            HStack
            {
                HeadingButton(title: "Left", command:"", width: buttonWidth)
                
                Picker("Angle", selection: $apvm.turnAngle) {
                    ForEach(apvm.turnAngles){turn in
                        Text(turn.name)
                            .tag(turn.value)
                    }
                }
                .frame(width: buttonHeight, height: buttonHeight)
                .padding(10)
                .background(.thickMaterial)
                .cornerRadius(buttonHeight/2)
                .disabled((ble.connectedToAp && gvm.navType == .none && apvm.actuatorEnabled) ? false : true)
                
                HeadingButton(title: "Right", command:"", width: buttonWidth)
            }
            .padding(5)
            
            HStack
            {
                HeadingButton(title: "Left 45", command:"h-45")
                HeadingButton(title: "Right 45", command:"h45")
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
            case "Left":
                cmd = "hi-\(apvm.turnAngle)"
                break
            case "Right":
                cmd = "hi\(apvm.turnAngle)"
                break
            case "Left 45":
                cmd = "hi-45"
                break
            case "Right 45":
                cmd = "hi45"
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

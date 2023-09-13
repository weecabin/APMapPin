//
//  BLEView.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/12/22.
//

import SwiftUI
//var bleManager = BLEManager()

struct BLEView: View {
    @State var textFieldText: String = ""
    @State var BLEName = "Adafruit Bluefruit LE"
    @State var GoToAPView:Bool = false
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var gvm:GlobalViewModel
    
    @EnvironmentObject var sceneDelegate : FSSceneDelegate
    
    @State var UrlString = ""
    var body: some View {
        
        VStack {
            Text(testUrlString() ?? "None")
            //Text(sceneDelegate.urlString!)
            BLEState
            scanList
            listButtons
            Spacer()
            NavigationLink(destination: APConfigView(), isActive: $GoToAPView) { }
        }
        .navigationTitle("Scan")
        .navigationBarItems(trailing: NavigationLink(
            destination: APConfigView(),
            label: {Text("Control")}))
        .onAppear {
            bleManager.hasAppeared(gvm:gvm)
        }
    }
}


extension BLEView{
    func testUrlString()->String?
    {
        if sceneDelegate.initialized{
            do {
                let text2 = try String(contentsOf: sceneDelegate.url!, encoding: .utf8)
                print(text2)
                return text2
            }
            catch {return "Error"}
        }
        return ""
    }
    
    private var listButtons: some View{
        Group{
            HStack{
                Button(action: {
                    bleManager.startScanning(stopOn: BLEName)
                }, label: {
                    Text("Start Scanning")
                })
                    .frame(height: 0)
                    .padding()
                    .background((!bleManager.connectedToAp ? Color.green : Color.gray) .cornerRadius(10))
                    .foregroundColor(bleManager.found ? .black : .white)
                    .disabled(bleManager.connectedToAp)
                
                if bleManager.scanning {StopScanning()}
            }

            HStack {
                Text("Find:")
                TextField("BLE Name", text: $BLEName)
            }
            .padding()
            
            HStack {
                Button(action: {
                    bleManager.connect()
                }, label: {
                    Text("Connect")
                })
                    .frame(height: 0)
                    .padding()
                    .background((bleManager.found && !bleManager.connectedToAp ? Color.green : Color.gray) .cornerRadius(10))
                    .foregroundColor(bleManager.found ? .black : .white)
                    .disabled(bleManager.connectedToAp || !bleManager.found)
                if bleManager.connectedToAp{DisConnect()}
            }
        }
    }
}

extension BLEView{
    private var BLEState: some View{
        HStack {
            Text("BLE On: ")
            bleManager.isSwitchedOn ? Text("Yes"):Text("No")
            Spacer()
            Text("Connected: ")
            bleManager.connectedToAp ? Text("Yes"):Text("No")
        }
        .padding()
        .onChange(of: bleManager.isSwitchedOn) { newValue in
            if bleManager.isSwitchedOn {
                bleManager.startScanning(stopOn: bleManager.peripheralName)
            }
        }
        .onChange(of: bleManager.connectedToAp) { newValue in
            if newValue {GoToAPView = true}
        }
    }
}

extension BLEView{
    private var scanList: some View{
        Group{
            List(bleManager.peripherals) { peripheral in
                HStack {
                    Text(peripheral.name)
                    Spacer()
                    Text(String(peripheral.rssi))
                }
            }
            .frame(height: 200)
        }
    }
}

struct StopScanning: View{
    @EnvironmentObject var bleManager: BLEManager
    var body: some View{
        Button(action: {
            bleManager.stopScanning()
        }, label: {
            Text("Stop Scanning")
        })
            .frame(height: 0)
            .padding()
            .background(Color.green .cornerRadius(10))
            .foregroundColor(.white)
    }
}

struct DisConnect: View{
    @EnvironmentObject var bleManager: BLEManager
    var body: some View{
        Button(action: {
            bleManager.disconnect()
        }, label: {
            Text("Disconnect")
        })
            .frame(height: 0)
            .padding()
            .background(Color.green .cornerRadius(10))
            .foregroundColor(.black)
    }
}

struct BLEView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView{
            BLEView()
                .environmentObject(BLEManager())
                .environmentObject(GlobalViewModel())
            }
            .navigationViewStyle(.stack)
        }
    }
}

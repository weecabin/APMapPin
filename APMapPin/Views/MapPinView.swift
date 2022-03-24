//
//  ContentView.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import SwiftUI

struct MapPinView: View {
    @StateObject var vm = CoreData.shared
    @State var name:String = ""
    @State var latitude:String = "30"
    @State var longitude:String = "-120"
    @State var selectedPin:MapPin?
    var body: some View {
        VStack(alignment: .leading){
            addNewPin
            editPins
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink("Routes",destination: RouteView())
            }
        }
    }
}

struct MapPinView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            MapPinView()
        }
        .environmentObject(MapPinViewModel())
    }
}

extension MapPinView{
    var addNewPin : some View{
        VStack{
            HStack{
                Text("Name:")
                TextField("name",text: $name)
            }
            HStack{
                Text("latitude:")
                TextField("latitude",text: $latitude)
            }
            HStack{
                Text("longitude:")
                TextField("longitude",text: $longitude)
            }
            HStack{
                Button {
                    if name.count > 0 {addMapPin()}
                } label: {
                    Text("Add")
                }
                .buttonStyle(.plain)
                .frame(width: 40, height: 30)
                .background(Color.blue)
                .cornerRadius(10)
                
                Button {
                    if selectedPin != nil {updatePin()}
                } label: {
                    Text("Update")
                }
                .buttonStyle(.plain)
                .frame(width: 70, height: 30)
                .background(selectedPin == nil ? Color.gray : Color.blue)
                .cornerRadius(10)
                .disabled(selectedPin == nil)
            }
            
        }
        .padding(.leading, 10)
    }
    
    var editPins : some View{
        VStack{
            Text("Map Pins")
                .font(.headline)
            List{
                ForEach(vm.savedPins.sorted()) {pin in
                    HStack{
                        Text("Name:")
                        Text(pin.Name)
                        Text(" (\(vm.countInRoutes(mapPin: pin)))")
                        Spacer()
                        Button {
                            deleteMapPin(pin: pin)
                        } label: {
                            Text("Del")
                        }
                        .buttonStyle(.plain)
                        .frame(width: 40, height: 30)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .onTapGesture {
                        selectedPin = pin
                        name = pin.Name
                        latitude = String(pin.latitude)
                        longitude = String(pin.longitude)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top,5)
            }
        }
    }
}

extension MapPinView{
    func deleteMapPin(pin: MapPin){
        name = ""
        latitude = ""
        longitude = ""
        selectedPin = nil
        vm.deleteMapPin(mapPin: pin)
    }
    func updatePin(){
        if let pin = selectedPin{
            pin.name = name
            pin.latitude = Double(latitude) ?? 0
            pin.longitude = Double(longitude) ?? 0
            vm.savePinData()
        }
    }
    
    func addMapPin(){
        if let lat = Double(latitude),
            let lon = Double(longitude){
            vm.addMapPin(name: name, latitude: lat, longitude: lon)
        }else{ // use the defaults
            vm.addMapPin(name: name)
        }
    }
}

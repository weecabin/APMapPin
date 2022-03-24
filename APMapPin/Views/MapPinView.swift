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
                    .padding()
            }
            Button {
                if name.count > 0 {vm.addMapPin(name: name)}
            } label: {
                Text("Add")
            }
            .buttonStyle(.plain)
            .frame(width: 40, height: 30)
            .background(Color.blue)
            .cornerRadius(10)
        }
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
                        Spacer()
                        Button {
                            vm.deleteMapPin(mapPin: pin)
                        } label: {
                            Text("Del")
                        }
                        .buttonStyle(.plain)
                        .frame(width: 40, height: 30)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top,5)
            }
        }
    }
}

//
//  RouteView.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import SwiftUI

struct RouteView: View {
    @StateObject var cd = CoreData.shared
    @State var name:String = ""
    @State var selectedRoute:Route?
    @State var pinPickerIndex:Int = 0
    var body: some View {
        VStack{
            addNewRoute
            Divider()
                .background(Color.black)
            if selectedRoute != nil{editRoute}
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink("RoutePoints",destination: RoutePointView())
            }
        }
    }
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            RouteView()
        }
        .environmentObject(MapPinViewModel())
        .previewInterfaceOrientation(.portraitUpsideDown)
    }
}

extension RouteView{
    var addNewRoute: some View{
        VStack{
            VStack{
                HStack{
                    Text("Name:")
                    TextField("name",text: $name)
                    
                    Button {
                        if name.count > 0 {cd.addRoute(name: name)}
                    } label: {
                        Text("Add")
                    }
                    .buttonStyle(.plain)
                    .frame(width: 40, height: 30)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            VStack{
                Text("Routes")
                    .font(.headline)
                List{
                    ForEach(cd.savedRoutes.sorted()) {route in
                        HStack{
                            Text("Name:")
                            Text(route.Name)
                            Spacer()
                            Button(action: {deleteRoute(route:route)},
                                   label: {Image(systemName: "trash.fill")})
                            .buttonStyle(.plain)
                            .frame(width: 40, height: 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                            Button(action: {selectedRoute = route},
                                   label: {Image(systemName: "pencil.circle")})
                                .buttonStyle(.plain)
                                .frame(width: 40, height: 30)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .frame(height: 250)
        }

    }
    
    var editRoute: some View{
        VStack{
            HStack{
                Text("Route \(selectedRoute!.Name)")
                    .padding()
                    .font(.headline)
                Picker("Pin", selection: $pinPickerIndex) {
                    ForEach(0..<cd.savedPins.count, id:\.self){index in
                        Text(cd.savedPins[index].Name).tag(index)
                    }
                }
                .border(.black, width: 2)
                Button(action: {addPinToRoute()}, label: {Text("Add Pin")})
                    .buttonStyle(.plain)
                    .frame(width: 80, height: 30)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            VStack{
                NavigationView{
                    List{
                        ForEach(selectedRoute!.routePointsArray){point in
                            HStack{
                                Text(point.pointPin?.Name ?? "?")
                                Text("\(point.index)")
                                Spacer()
                                Button(action: {deleteRoutePoint(point: point)},
                                       label: {Image(systemName: "trash.fill")})
                                .buttonStyle(.plain)
                                .frame(width: 40, height: 30)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                        }
                        .onMove(perform: onMoveRoutePin)
                    }
                    .toolbar{EditButton()}
                    .navigationTitle("Route Pins")
                }
            }
        }
    }
    
    func deleteRoute(route:Route){
        if selectedRoute == route{
            selectedRoute = nil
        }
        cd.deleteRoute(route: route)
    }
    
    func onMoveRoutePin(from:IndexSet, to:Int){
        cd.moveRoutePoint(route: selectedRoute!, from: from.first!, to: to)
    }
    
    func addPinToRoute(){
        let pin = cd.savedPins[pinPickerIndex]
        cd.addPinToRoute(route: selectedRoute!, pin: pin)
    }
    
    func deleteRoutePoint(point:RoutePoint){
        cd.deleteRoutePoint(routePoint: point)
    }
}

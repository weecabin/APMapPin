//
//  RouteView.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import SwiftUI

struct RouteView: View {
    @StateObject var cd = CoreData()
    @State var name:String = ""
    @State var editRoute:Route?
    @State var addPinIndex:Int = 0
    var body: some View {
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
                            Button(action: {editRoute = route},
                                   label: {Image(systemName: "pencil.circle")})
                                .buttonStyle(.plain)
                                .frame(width: 40, height: 30)
                                .background(Color.blue)
                        }
                    }
                }
            }
            .frame(height: 250)
            Divider()
                .background(Color.black)
            if editRoute != nil{
                VStack{
                    HStack{
                        Text("Route \(editRoute!.Name)")
                            .padding()
                            .font(.headline)
                        Picker("Pin", selection: $addPinIndex) {
                            ForEach(0..<cd.savedPins.count, id:\.self){index in
                                Text(cd.savedPins[index].Name).tag(index)
                            }
                        }
                        .border(.black, width: 2)
                        Button(action: {addPinToRoute()}, label: {Text("Add Pin")})
                    }
                    VStack{
                        NavigationView{
                            List{
                                ForEach(editRoute!.routePointsArray){point in
                                    HStack{
                                        Text(point.pointPin?.Name ?? "?")
                                        Text("\(point.index)")
                                        Spacer()
                                        Button(action: {deleteRoutePoint(point: point)},
                                               label: {Image(systemName: "trash.fill")})
                                        .buttonStyle(.plain)
                                        .frame(width: 40, height: 30)
                                        .background(Color.blue)
                                    }
                                }
                                .onMove(perform: onMoveRoutePin)
                            }
                            .toolbar{EditButton()}
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        .navigationBarItems(trailing:NavigationLink("RoutePoints",destination: RoutePointView()))
    }
    
    func deleteRoute(route:Route){
        if editRoute == route{
            editRoute = nil
        }
        cd.deleteRoute(route: route)
    }
    
    func onMoveRoutePin(from:IndexSet, to:Int){
        cd.moveRoutePoint(route: editRoute!, from: from.first!, to: to)
    }
    
    func addPinToRoute(){
        let pin = cd.savedPins[addPinIndex]
        cd.addPinToRoute(route: editRoute!, pin: pin)
    }
    
    func deleteRoutePoint(point:RoutePoint){
        cd.deleteRoutePoint(routePoint: point)
    }
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            RouteView()
        }
        .environmentObject(MapPinViewModel())
    }
}

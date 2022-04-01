//
//  RouteEditView.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/1/22.
//

import SwiftUI

struct RouteEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var cd = CoreData.shared
    var route:Route
    @State var forceUpdate:Bool = false
    @State var pinPickerIndex=0
    var body: some View {
        editRoute
    }
}

struct RouteEditView_Previews: PreviewProvider {
    static var previews: some View {
        RouteEditView(route: CoreData.shared.savedRoutes[0])
    }
}

extension RouteEditView{
    var editRoute: some View{
        VStack{
            Text(route.Name)
            HStack{
                Spacer()
                Button("Exit"){presentationMode.wrappedValue.dismiss()}
                Spacer()
                Text("Select Pin >")
                Picker("Pin", selection: $pinPickerIndex) {
                    ForEach(0..<cd.savedPins.count, id:\.self){index in
                        Text(cd.savedPins[index].Name).tag(index)
                    }
                }
                .border(.black, width: 2)
                Button(action: {addPinToRoute()}, label: {Text("Add")})
                    .buttonStyle(.plain)
                    .frame(width: 80)
                    .background(Color.blue)
                    .cornerRadius(10)
                Spacer()
            }
            VStack{
                Text(forceUpdate ? "" : "")
                    .hidden()
                NavigationView{
                    List{
                        ForEach(route.routePointsArray){point in
                            HStack{
                                Text(point.pointPin?.Name ?? "?")
                                Text("\(point.index)")
                                if point.target{
                                    Image(systemName: "target")
                                }
                                Spacer()
                                Button(action: {targetThisPoint(point: point)},
                                       label: {Image(systemName: "target")})
                                .buttonStyle(.plain)
                                .frame(width: 40, height: 30)
                                .background(Color.blue)
                                .cornerRadius(10)
                                
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
                    .navigationTitle("Route \(route.Name)")
                    //.navigationBarHidden(true)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
    
    func addPinToRoute(){
        let pin = cd.savedPins[pinPickerIndex]
        cd.addPinToRoute(route: route, pin: pin)
    }
    
    func onMoveRoutePin(from:IndexSet, to:Int){
        cd.moveRoutePoint(route: route, from: from.first!, to: to)
    }
    
    func ForceUpdate(){
        forceUpdate.toggle()
    }
    
    func targetThisPoint(point: RoutePoint){
        for p in point.pointRoute!.routePointsArray{
            if p == point{
                p.target = true
            }else{
                p.target = false
            }
        }
        ForceUpdate()
    }
    
    func deleteRoutePoint(point:RoutePoint){
        cd.deleteRoutePoint(routePoint: point)
    }
}

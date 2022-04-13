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
    @State var name:String=""
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
            HStack{
                Button("< Exit"){presentationMode.wrappedValue.dismiss()}
                Spacer()
            }.padding()
            
            HStack{
                Text("Route:")
                TextField("name", text: $name)
                Spacer()

                Button {
                    updateRouteName()
                } label: {
                    Text("Update")
                }
                .buttonStyle(.plain)
                .frame(width: 80, height: 30)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            HStack{

                Text("Select Pin >")
                Picker("Pin", selection: $pinPickerIndex) {
                    ForEach(0..<cd.savedPins.count, id:\.self){index in
                        Text("\(cd.savedPins[index].Name)(\(cd.savedPins[index].unwrappedType))")
                            .tag(index)
                    }
                }

                Spacer()
                Button(action: {addPinToRoute()}, label: {Text("Add")})
                    .buttonStyle(.plain)
                    .frame(width: 80, height: 30)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.padding()
            VStack{
                Text(forceUpdate ? "" : "")
                    .hidden()
                NavigationView{
                    List{
                        ForEach(route.routePointsArray){point in
                            HStack{
                                Text(point.pointPin?.Name ?? "?")
                                Text("(\(point.pointPin!.unwrappedType))")
                                Text("\(point.index)")
                                if point.target{
                                    Image(systemName: "target")
                                }
                                Spacer()
                                
                                Button(action: {
                                    cd.setTarget(route: route, targetPoint: point)
                                    ForceUpdate()
                                },label: {Image(systemName: "target")})
                                .buttonStyle(.plain)
                                .frame(width: 40, height: 30)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                
                                Button(action: {deleteRoutePoint(point: point)},
                                       label: {Image(systemName: "trash.fill")})
                                .buttonStyle(.plain)
                                .frame(width: 40, height: 30)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .onMove(perform: onMoveRoutePin)
                    }
                    .toolbar{EditButton()}
                }
            }
        }
        .onAppear {
            name = route.Name
        }
    }
    
    func updateRouteName(){
        cd.ChangeRouteName(route: route, name: name)
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
    
    func deleteRoutePoint(point:RoutePoint){
        cd.deleteRoutePoint(routePoint: point)
    }
}

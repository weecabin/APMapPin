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
//    @State var forceUpdate:Int = 0
    @State var editThisRoute:Route?
    @State var deleteThisRoute:Route?
    var body: some View {
        VStack{
            addNewRoute
            Spacer()
        }
        .onAppear(perform: {
            if cd.savedRoutes.count > 0{
                selectedRoute = cd.savedRoutes[0]
            }
        })
        .padding()
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
                        .textInputAutocapitalization(.never)
                    
                    Button {
                        if name.count > 0 {
                            cd.addRoute(name: name)
                            print("Adding Route")
                        }else{
                            print("Nothing to add")
                        }
                        
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
                            Text(route.Name)
                            route.visible ? Image(systemName: "eye") : Image(systemName: "eye.slash")
                            if route.active{Image(systemName: "checkmark")}
                            Spacer()
                            
                            Button(action: {setActiveRoute(route: route)},
                                   label: {Image(systemName: "checkmark")})
                            .buttonStyle(.plain)
                            .frame(width: 30, height: 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                            
                            Button(action: {toggleRouteVisible(route: route)},
                                   label: {Image(systemName: "eye")})
                            .buttonStyle(.plain)
                            .frame(width: 30, height: 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                            
                            Button(action: {deleteThisRoute = route},
                                   label: {Image(systemName: "trash.fill")})
                            .buttonStyle(.plain)
                            .frame(width: 30, height: 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                            
                            Button(action: {editThisRoute = route},
                                   label: {Image(systemName: "pencil.circle")})
                            .buttonStyle(.plain)
                            .frame(width: 30, height: 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .sheet(item: $editThisRoute){route in
                            RouteEditView(route: route)
                        }
                        .alert(item: $deleteThisRoute, content: { route in
                            getDeleteAlert(title: "Delete", message: "Route: \(route.Name)") {
                                deleteRoute(route: route)
                            }
                        })
                    }
                }
            }
        }
    }
    
    func getDeleteAlert(title:String, message:String, action:(()->Void)?) ->Alert{
        return Alert(
            title: Text(title),
            message: Text(message),
            primaryButton: .default(Text("OK"), action: action),
            secondaryButton: .cancel())
    }
    
    func setActiveRoute(route:Route){
        if route == cd.getActiveRoute() || !route.visible{return}
        if let activeRoute = cd.getActiveRoute(){
            cd.ClearSelectedPins(route:activeRoute)
        }
        cd.setActiveRoute(activeRoute: route);
        cd.saveRoutePointData()
    }
    
    func toggleRouteVisible(route:Route){
        route.visible.toggle()
        if !route.visible{
            cd.clearTargetedPin(route: route)
            cd.ClearSelectedPins(route: route)
            if route.active{
                // make the first visible route active
                route.active=false
                for visRoute in cd.getVisibleRoutes(){
                    if visRoute.visible{
                        visRoute.active = true
                        break
                    }
                }
            }else{ // make this route the active route if there is no visible active route
                if !cd.isActiveRouteVisible(){
                    cd.setActiveRoute(activeRoute: route)
                }
            }
        }
        cd.saveRouteData()
        cd.saveRoutePointData()
    }

    func deleteRoute(route:Route){
        if selectedRoute == route{
            selectedRoute = nil
        }
        cd.deleteRoute(route: route)
    }
}

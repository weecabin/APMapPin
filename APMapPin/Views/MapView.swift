//
//  MapView.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/25/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    let defaults = UserDefaults.standard
    @EnvironmentObject var mvm:MapViewModel
    @State var routePickerIndex = 0
    var body: some View {
        ZStack{
            mapView
            fixMenuView
            locationDetailsView
        }
        .onAppear {
            mvm.initMap()
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(MapViewModel())
    }
}
    
extension MapView{
    var mapView : some View{
        Map(coordinateRegion: $mvm.region,
            interactionModes: MapInteractionModes.all ,
            showsUserLocation: true,
            annotationItems: mvm.cd.namedRouteArray(name: activeRoute()!.Name)) { pin in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: pin.pointPin!.latitude, longitude: pin.pointPin!.longitude)) {
                switch pin.pointPin!.type {
                case "fish":
                    FishAnnotationView(label: pin.pointPin!.Name, rotate: pin.pointPin!.course)

                case "home":
                    HomeAnnotationView(label: pin.pointPin!.Name)

                case "shallow":
                    ShallowAnnotationView(label: pin.pointPin!.Name)
                    
                case "fix":
                    WaypointAnnotationView(label: "\(pin.pointPin!.Name)-\(pin.index)", backColor: pin.target ? mvm.routePinColor : .clear)
                    
                default:
                    WaypointAnnotationView(label: pin.pointPin!.Name)
                }
            }
        }
    }
    
    var fixMenuView : some View{
        ZStack{
            VStack{
                Text("")
                HStack{
                    Spacer()
                    Picker("Pin", selection: $routePickerIndex) {
                        ForEach(0..<mvm.cd.savedRoutes.count, id:\.self){index in
                            Text(mvm.cd.savedRoutes[index].Name).tag(index)
                        }
                    }
                    .frame(width: 100)
                    .border(.black, width: 2)
                    Spacer()

                    Button {
                        let pin = mvm.cd.addMapPin(name: "fix", latitude: mvm.region.center.latitude, longitude: mvm.region.center.longitude, type: "fix")
                        mvm.cd.addPinToRoute(routeName: activeRoute()!.Name, pin: pin)
                        print("Adding Pin to Route")
                    } label: {
                        Text("Add Fix")
                            .buttonStyle(.plain)
                            .frame(width: 70, height: 30)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                    
                    Button {
                        nextTarget()
                    } label: {
                        Text("Next")
                            .buttonStyle(.plain)
                            .frame(width: 70, height: 30)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                    
                    Button {
                        mvm.Navigate(route: activeRoute()!)
                    } label: {
                        Text("Run")
                            .buttonStyle(.plain)
                            .frame(width: 70, height: 30)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                
                Spacer()
            }
            Text("X")
        }
    }
    
    var locationDetailsView : some View{
        VStack{
            Spacer()
            HStack{
                Text("> spd:\(mvm.lastLocationSpeed) crs:\(mvm.lastLocationCourse)")
                Spacer()
            }
            .background(.gray)
            HStack{
                Text("Nav: \(mvm.navigate.distToTargetString) \(mvm.navigate.currentHeadingToTargetString)")
                Spacer()
            }
            .background(.gray)
            Text("")
        }
    }
    
    func nextTarget(){
        if let route = activeRoute(){
            if route.routePointsArray.count == 0 {return}
            for rp in route.routePointsArray{
                if rp.target{
                    if rp.index >= route.routePointsArray.count-1{
                        print("target index = 0")
                        route.routePointsArray[0].setTarget(enabled: true)
                    }else{
                        let index = Int(rp.index + 1)
                        print("target index = \(index)")
                        route.routePointsArray[index].setTarget(enabled: true)
                    }
                    rp.setTarget(enabled: false)
                    return
                }
            }
            route.routePointsArray[0].setTarget(enabled: true)
        }
    }
    
    func activeRoute() -> Route?{
        if mvm.cd.savedRoutes.count > 0{
            return mvm.cd.savedRoutes[routePickerIndex]
        }
        return nil
    }
}

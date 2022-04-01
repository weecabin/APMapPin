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

    var body: some View {
        ZStack{
            mapView
            fixMenuView
            locationDetailsView
        }
        .onAppear {
            mvm.initMap()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink("Routes",destination: RouteView())
            }
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
            annotationItems: mvm.cd.namedRouteArray(name: mvm.activeRoute()!.Name)) { pin in
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
                Text(mvm.updateView ? "" : "")
                HStack{
                    Spacer()
                    Picker("Pin", selection: $mvm.routePickerIndex) {
                        ForEach(0..<mvm.cd.savedRoutes.count, id:\.self){index in
                            Text(mvm.cd.savedRoutes[index].Name).tag(index)
                        }
                    }
                    .frame(width: 70)
                    .border(.black, width: 2)
                    .disabled(mvm.running)
                    Spacer()
                    
                    Button {
                        mvm.AddRoutePoint(route: mvm.activeRoute()!)
                    } label: {
                        AddPinToRouteView()
                            .buttonStyle(.plain)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        mvm.Navigate(route: mvm.activeRoute()!)
                    } label: {
                        RunRouteView()
                            .buttonStyle(.plain)
                            .background(mvm.running ? .gray : .blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(mvm.running)
                    
                    Button {
                        mvm.StopNavigation()
                    } label: {
                        StopRouteView()
                            .buttonStyle(.plain)
                            .background(mvm.running ? .blue : .gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!mvm.running)
                    
                    Button {
                        mvm.DeleteRoutePoints(route: mvm.activeRoute()!)
                    } label: {
                        DeleteRouteView()
                            .buttonStyle(.plain)
                            .background(mvm.running ? .gray : .blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(mvm.running)
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
                mvm.navigate.running ? Text("Nav: \(mvm.navigate.distToTargetString) \(mvm.navigate.bearingToTargetString)") :
                Text("")
                Spacer()
            }
            .background(.gray)
            Text("")
        }
    }
}

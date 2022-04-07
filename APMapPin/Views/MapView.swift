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
    @State var selectedPin:MapPin?
    @State var selectedRoute:Route?

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
            annotationItems: mvm.cd.visiblePointsArray()) { pin in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: pin.pointPin!.latitude, longitude: pin.pointPin!.longitude)) {
                switch pin.pointPin!.type {
                case "fish":
                    FishAnnotationView(label: pin.pointPin!.Name, rotate: pin.pointPin!.course, accentColor: pin.pointRoute!.active ? .blue : .gray)
                        .onTapGesture {
                            mvm.cd.toggleSelected(point: pin)
                            mvm.UpdateView()
                        }
                        .scaleEffect(pin.selected ? 1.5 : 1.0)

                case "home":
                    HomeAnnotationView(label: pin.pointPin!.Name)
                        .onTapGesture {
                            mvm.cd.toggleSelected(point: pin)
                            mvm.UpdateView()
                        }
                        .scaleEffect(pin.selected ? 1.5 : 1.0)

                case "shallow":
                    ShallowAnnotationView(label: pin.pointPin!.Name)
                        .onTapGesture {
                            mvm.cd.toggleSelected(point: pin)
                            mvm.UpdateView()
                        }
                        .scaleEffect(pin.selected ? 1.5 : 1.0)
                    
                case "fix":
                    WaypointAnnotationView(label: "\(pin.pointPin!.Name)-\(pin.index)",
                                           backColor: pin.target && pin.pointRoute!.active ? mvm.routePinColor : .clear,
                            accentColor: pin.pointRoute!.active ? .blue : .gray)
                        .onTapGesture {
                            mvm.cd.toggleSelected(point: pin)
                            print("annotation tap \(mvm.cd.selectedRoutePoints.count)")
                            mvm.UpdateView()
                            print("selected pin count: \(mvm.cd.selectedPinCount())")
                        }
                        .scaleEffect(pin.selected ? 1.5 : 1.0)
                case "sim":
                    SimAnnotationView(label: pin.pointPin!.Name, rotate: pin.pointPin!.course, accentColor: pin.pointRoute!.active ? .blue : .gray)
                        .onTapGesture {
                            mvm.cd.toggleSelected(point: pin)
                            mvm.UpdateView()
                        }
                    
                default:
                    WaypointAnnotationView(label: pin.pointPin!.Name, accentColor: pin.pointRoute!.active ? .blue : .gray)
                        .onTapGesture {
                            mvm.cd.toggleSelected(point: pin)
                            mvm.UpdateView()
                        }
                }
            }
        }
            .ignoresSafeArea()
    }
    
    var fixMenuView : some View{
        ZStack{
            VStack{
                Text(mvm.updateView ? "" : "")
                HStack{
                    Spacer()
                    Button {
                        if mvm.cd.selectedRoutePoints.count == 1{
                            mvm.StopBlinkTimer()
                            selectedPin = mvm.cd.selectedRoutePoints[0].pointPin
                            print(selectedPin!)
                        }
                    } label: {
                        EditView()
                            .buttonStyle(.plain)
                            .background(enablePinEdit() ? .blue : .gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!enablePinEdit())
                           
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
                        mvm.AddRoutePoint(route: mvm.activeRoute()!, source: .Location)
                    } label: {
                        AddLocationView()
                            .buttonStyle(.plain)
                            .background(enableAddLocation() ? .blue : .gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!enableAddLocation())
                    
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
                        mvm.DeleteSelectedPoints()
                    } label: {
                        DeleteRouteView()
                            .buttonStyle(.plain)
                            .background(enableDeletePin() ? .blue : .gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!enableDeletePin())
                    Spacer()
                }
                
                Spacer()
            }
            .fullScreenCover(item: $selectedRoute,
                             onDismiss: {mvm.cd.saveRouteData();if mvm.running{mvm.StartBlinkTimer()}},
                             content: {RouteEditView(route: $0)})
            .fullScreenCover(item: $selectedPin,
                             onDismiss: {mvm.editPinDismissed();if mvm.running{mvm.StartBlinkTimer()}},
                             content: {EditPinView(mapPin: $0) })
            Text("X")
        }
    }
    func enablePinEdit()->Bool{
//        print("\(mvm.cd.selectedPinCount()) selected pins")
        return mvm.cd.selectedPinCount() == 1
    }
    func enableDeletePin()->Bool{
        !mvm.running && mvm.cd.selectedPinCount()>0
    }
    
    func enableAddLocation()->Bool{
        if let loc = mvm.lastLocation{
            return loc.course >= 0
        }
        return false
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
                mvm.navigate.running ? Text("Nav: \(mvm.navigate.distToTargetString) \(mvm.navigate.bearingToTargetString)/ \(mvm.navigate.desiredBearingToTargetString)") :
                Text("")
                Spacer()
            }
            .background(.gray)
            Text("")
        }
    }
}

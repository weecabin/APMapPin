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
    @State var deleteSelectedPins:Bool = false
    var body: some View {
        ZStack{
            mapView
            topButtonView
            locationDetailsView
        }
        .onAppear {
            mvm.initMap()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack{
                    NavigationLink("Settings", destination: SettingsView())
                    NavigationLink("Routes",destination: RouteView())
                }
            }
        }
    }
}

extension MapView{
    var mapView : some View{
        Map(coordinateRegion: $mvm.region,
            interactionModes: MapInteractionModes.all ,
            showsUserLocation: true,
            annotationItems: mvm.cd.visiblePointsArray()) { pin in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: pin.pointPin!.latitude, longitude: pin.pointPin!.longitude)) {
                AnnotationView(type:pin.pointPin!.type!,
                               label: "\(pin.pointPin!.Name)\(pin.suffix)",
                               rotate: pin.pointPin!.course,
                               foreColor: pin.pointRoute!.active ? .blue : .gray,
                               backColor: pin.target && pin.pointRoute!.active ? mvm.routePinColor : .clear)
                    .onTapGesture {
                        mvm.cd.toggleSelected(point: pin)
                        mvm.UpdateView()
                    }
                    .scaleEffect(pin.selected ? 1.5 : 1.0)
            }
        }
            .ignoresSafeArea()
    }
    
    var topButtonView : some View{
        ZStack{
            VStack{
                Text(mvm.updateView ? "" : "")
                HStack{
                    Spacer()
                    Button {
                        mvm.StartStopBreadCrumbs()
                    } label: {
                        AddBreadCrumbsView()
                            .buttonStyle(.plain)
                            .background(mvm.droppingCrumbs ? .orange : .blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
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
                            .background(enableButton() ? .blue : .gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!enableButton())
                    
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
                        if mvm.running{mvm.StopNavigation()}
                        else{mvm.Navigate(route: mvm.activeRoute()!)}
                    } label: {
                        RunRouteView()
                            .buttonStyle(.plain)
                            .background(navButtonCollor())
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!enableButton())
                    
                    Button {
                        deleteSelectedPins = true
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
            .alert(isPresented: $deleteSelectedPins) {
                Alert(title: Text("Delete Selected Pins"),
                      primaryButton: .default(Text("OK"), action: {mvm.DeleteSelectedPoints()}),
                      secondaryButton: .cancel())
            }
            Text("X")
        }
        
    }
    
    func enableButton()->Bool{
        for route in mvm.cd.savedRoutes{
            if route.visible && route.active{
                return true
            }
        }
        return false
    }
    
    func enableStartNavButton()->Bool{
        if !enableButton(){return false}
        if !mvm.running{
            return true
        }
        return false
    }
    
    func navButtonCollor()->Color{
        if !enableButton(){return .gray}
        if mvm.running{return .orange}
        return .blue
    }
    
    func enableStopNavButton()->Bool{
        if !enableButton(){return false}
        if mvm.running{
            return true
        }
        return false
    }

    func enablePinEdit()->Bool{
        if !enableButton(){return false}
        return mvm.cd.selectedPinCount() == 1
    }
    
    func enableDeletePin()->Bool{
        if !enableButton(){return false}
        return !mvm.running && mvm.cd.selectedPinCount()>0
    }
    
    func enableAddLocation()->Bool{
        if !enableButton(){return false}
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

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(MapViewModel())
    }
}
    

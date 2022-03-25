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
    @StateObject var cd = CoreData.shared
    @State var region:MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.97869683639129, longitude: -120.53599956870863), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @State var routePickerIndex = 0
    @State var blinkActivePinTimer:Timer?
    @State var pinColor:Color = .red
    @State var initialized:Bool = false
    var body: some View {
        ZStack{
            mapView
            addFix
        }
        .onAppear {
            initMap()
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
    
extension MapView{
    var mapView : some View{
        Map(coordinateRegion: $region,
            interactionModes: MapInteractionModes.all ,
            showsUserLocation: true,
            annotationItems: cd.namedRouteArray(name: activeRoute()!.Name)) { mp in
//            annotationItems: cd.namedRouteArray(name: cd.savedRoutes[routePickerIndex].Name)) { mp in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: mp.pointPin!.latitude, longitude: mp.pointPin!.longitude)) {
                switch mp.pointPin!.type {
                case "fish":
                    FishAnnotationView(label: mp.pointPin!.Name, rotate: mp.pointPin!.course)

                case "home":
                    HomeAnnotationView(label: mp.pointPin!.Name)

                case "shallow":
                    ShallowAnnotationView(label: mp.pointPin!.Name)
                    
                case "fix":
                    WaypointAnnotationView(label: "\(mp.pointPin!.Name)-\(mp.index)", backColor: mp.target ? pinColor : .clear)
                    
                default:
                    WaypointAnnotationView(label: mp.pointPin!.Name)
                }
            }
        }
    }
    
    var addFix : some View{
        ZStack{
            VStack{
                Text("")
                HStack{
                    Spacer()
                    Picker("Pin", selection: $routePickerIndex) {
                        ForEach(0..<cd.savedRoutes.count, id:\.self){index in
                            Text(cd.savedRoutes[index].Name).tag(index)
                        }
                    }
                    .frame(width: 100)
                    .border(.black, width: 2)
                    Spacer()

                    Button {
                        let pin = cd.addMapPin(name: "fix", latitude: region.center.latitude, longitude: region.center.longitude, type: "fix")
                        cd.addPinToRoute(routeName: activeRoute()!.Name, pin: pin)
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
                }
                
                Spacer()
            }
            Text("X")
        }
    }
    
    func initMap(){
        if !initialized{
            blinkActivePinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { Timer in
                self.blinkPin()
            }
            initialized = true
        }
    }
    
    func nextTarget(){
        if let route = activeRoute(){
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
                    break
                }
            }
        }
    }
    
    func activeRoute() -> Route?{
        if cd.savedRoutes.count > 0{
            return cd.savedRoutes[routePickerIndex]
        }
        return nil
    }
    
    func blinkPin(){
//        print("in blinkPin")
        switch (pinColor){
        case .yellow:
            pinColor = .green
            break
        case .green:
            pinColor = .yellow
            break
        default:
            pinColor = .green
            break
        }
//        print(pinColor)
    }
}

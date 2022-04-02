//
//  MapViewModel.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/25/22.
//

import SwiftUI
import MapKit

protocol NavCompleteDelegate{
    func NavComplete()
}

class MapViewModel : NSObject, ObservableObject, CLLocationManagerDelegate, NavCompleteDelegate{
    func NavComplete() {
        print("in NavCompleteDelegate")
        StopBlinkTimer()
    }
    
    @Published var region:MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.97869683639129, longitude: -120.53599956870863), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @Published var cd = CoreData.shared
    @Published var routePickerIndex = 0
    
    @Published var updateView:Bool = false
    var locationManager : CLLocationManager?
    var navigate:NavigateRoute = NavigateRoute()
    var mapInitialized:Bool = false
    
    var lastLocation:CLLocation?
    var lastLocationSpeed:String = ""
    var lastLocationCourse:String = ""
    
    @Published var routePinColor:Color = .red
    var blinkPinTimer:Timer?
    
    func initMap(){
        if !mapInitialized{
            checkLocationServicesIsOn()
            mapInitialized = true
            navigate.navCompleteDeletate = self
        }
    }
    
    func StartBlinkTimer(){
        blinkPinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { Timer in
            self.blinkPinColor()
        }
    }
    func StopBlinkTimer(){
        if let timer = blinkPinTimer{
            timer.invalidate()
        }
    }
    func blinkPinColor(){
        switch (routePinColor){
        case .yellow:
            routePinColor = .green
            break
        case .green:
            routePinColor = .yellow
            break
        default:
            routePinColor = .green
            break
        }
    }
    
    func UpdateView(){
        updateView.toggle()
    }
}

extension MapViewModel{ // Navigation Functions
    var running:Bool{
        return navigate.running
    }
    
    func activeRoute() -> Route?{
        if cd.savedRoutes.count > 0{
            return cd.savedRoutes[routePickerIndex]
        }
        return nil
    }
    
    func AddRoutePoint(route: Route){
        let pin = cd.addMapPin(name: "fix", latitude: region.center.latitude, longitude: region.center.longitude, type: "fix")
        cd.addPinToRoute(routeName: route.Name, pin: pin)
        UpdateView()
        print("Adding Pin to Route")
    }
    
    func DeleteRoutePoints(route: Route){
        while route.routePointsArray.count > 0{
            cd.deleteRoutePoint(routePoint: route.routePointsArray[0])
        }
        UpdateView()
    }
    
    func Navigate(route: Route){
        if !navigate.StartNavigation(route: route){
            print("Failed to start navigation")
        }
        StartBlinkTimer()
        UpdateView()
    }
    
    func StopNavigation(){
        StopBlinkTimer()
        navigate.CancelNavigation()
        if let route = activeRoute(){
            for point in route.routePointsArray{
                point.target = false
            }
        }
        UpdateView()
    }
    
}

extension MapViewModel{ // Location calls
    func checkLocationServicesIsOn(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager!.distanceFilter = 0.1
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
        }
        else{
            print("turn location services on")
        }
    }
    
    private func checkLocationAuthorization(){
        print("checkLocationAuthorization")
        guard let locationManager = locationManager else {return}
        
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("your location is restricted")
        case .denied:
            print("you have denied this app location priveliges")
        case .authorizedAlways, .authorizedWhenInUse:
            if let location = locationManager.location {
                region = MKCoordinateRegion(center: mapInitialized ? region.center : location.coordinate,
                                            span: region.span)
            mapInitialized = true
            locationManager.startUpdatingLocation()
        }
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        lastLocation = location
        navigate.lastLocation = lastLocation
        
        var speed = lastLocation!.speed
        speed = (speed >= 0) ? speed * 2.23694 : 0
        lastLocationSpeed =  String(format: "%.1f",speed)
        
        let heading = lastLocation!.course
        if heading >= 0 {
            lastLocationCourse = String(format: "%.1f",heading)
        }
        else{
            lastLocationCourse = "?"
        }
    }

}

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
    @Published var region:MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.97869683639129, longitude: -120.53599956870863), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @Published var cd = CoreData.shared
    
    @Published var updateView:Bool = false
    var locationManager : CLLocationManager?
    var navigate:NavigateRoute = NavigateRoute()
    var mapInitialized:Bool = false
    
    var lastLocation:CLLocation?
    var lastLocationSpeed:String = ""
    var lastLocationCourse:String = ""
    
    @Published var routePinColor:Color = .red
    var blinkPinTimer:Timer?
    
    var simPin:MapPin?
    var simInitialized:Bool = false
    var simStartLocation:CLLocationCoordinate2D?
    
    func initMap(){
        if !mapInitialized{
            checkLocationServicesIsOn()
            mapInitialized = true
            navigate.navCompleteDeletate = self
        }
        UpdateView()
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
        if simPin != nil {
            UpdateSimulatedLocation()
        }
        UpdateHeading()
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
//        print("running: \(navigate.running)")
        return navigate.running
    }
    
    func Navigate(route: Route){
        if simPin != nil{
            simInitialized = false
            UpdateSimulatedLocation()
            if !navigate.StartNavigation(route: route, arrivalZone: 10){
                print("Failed to start navigation")
                simPin = nil
                return
            }
        }else{
            if !navigate.StartNavigation(route: route, arrivalZone: 30){
                print("Failed to start navigation")
                return
            }
        }
        UpdateHeading()
        StartBlinkTimer()
        UpdateView()
    }
    
    func StopNavigation(){
        navigate.CancelNavigation()
    }
    
    func UpdateHeading(){
        if let pin = simPin{
            let headingError = HeadingError(target: navigate.bearingToTarget!, actual: pin.course)
            //print("bearing: \(navigate.bearingToTargetString) course: \(pin.course) error: \(courseError)")
            let newCourseToTarget = FixHeading(heading: simPin!.course - headingError)
            let courseError = HeadingError(target: navigate.desiredBearingToTarget!, actual: newCourseToTarget)
            print("desired course Error \(courseError)")
            simPin!.course = newCourseToTarget + courseError
        }else{
            if let lastLoc = lastLocation{
                let lastLocCourse = lastLoc.course
                let headingError = HeadingError(target: navigate.bearingToTarget!, actual: lastLocCourse)
                //print("bearing: \(navigate.bearingToTargetString) course: \(pin.course) error: \(courseError)")
                let newCourseToTarget = FixHeading(heading: lastLocCourse - headingError)
                let courseError = HeadingError(target: navigate.desiredBearingToTarget!, actual: newCourseToTarget)
                print("new course \(newCourseToTarget + courseError)")
            }
        }
    }
    
    func UpdateSimulatedLocation(){
        if let pin = simPin{
            if !simInitialized{
                simStartLocation = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                simInitialized = true
            }
            let distanceTraveled = Float(3)
            let newCoord = getNewTargetCoordinate(
                position: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude),
                userBearing: Float(pin.course),
                distance: distanceTraveled)
            pin.latitude = newCoord.latitude
            pin.longitude = newCoord.longitude
            //print("simPin lat: \(pin.latitude) lon: \(pin.longitude)")
            lastLocation = CLLocation(coordinate: newCoord, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: pin.course, speed: 3, timestamp: Date.now)
            //print("UpdateSimulatedLocation lastLocation = \(lastLocation!)")
            navigate.lastLocation = lastLocation
            var speed = lastLocation!.speed
            speed = (speed >= 0) ? speed * 2.23694 : 0
            lastLocationSpeed =  String(format: "%.1f",speed)
            
            let heading = lastLocation!.course
            if heading >= 0 {lastLocationCourse = String(format: "%.1f",heading)}
            else{lastLocationCourse = "?"}
        }
    }
    
    func NavComplete() {
        print("in NavCompleteDelegate")
        StopBlinkTimer()
        if simPin != nil{
            simPin!.latitude = simStartLocation!.latitude
            simPin!.longitude = simStartLocation!.longitude
            simPin!.type = "fix"
            print("nulling simPin")
            simPin = nil
        }
        if let route = activeRoute(){
            for point in route.routePointsArray{
                point.selected = false
                point.target = false
//                point.pointPin!.type = "fix"
            }
        }
        cd.saveRoutePointData()
        cd.savePinData()
        UpdateView()
    }
    
    func editPinDismissed(){
        checkForSimPin()
        UpdateView();
        print("EditPinView dismissed")
    }
    
    func checkForSimPin(){
        simPin = nil
        for pin in activeRoute()!.routePointsArray{
            if pin.pointPin!.type == "sim"{
                simPin = pin.pointPin
                return
            }
        }
    }
    
    func activeRoute() -> Route?{
        if cd.savedRoutes.count > 0{
            return cd.getActiveRoute()
        }
        return nil
    }
    enum LocationSource{
        case X
        case Location
    }
    func AddRoutePoint(route: Route, source:LocationSource = .X){
        var pin:MapPin?
        if source == .X{
            pin = cd.addMapPin(name: "fix", latitude: region.center.latitude, longitude: region.center.longitude, type: "fix")
        }else{
            if let loc = lastLocation{
                pin = cd.addMapPin(name: "fish", location: loc, type: "fish")
            }else{
                return
            }
        }
        cd.addPinToRoute(routeName: route.Name, pin: pin!)
        UpdateView()
        print("Adding Pin to Route")
    }
    
    func DeleteSelectedPoints(){
        for point in cd.selectedRoutePoints{
            cd.deleteRoutePoint(routePoint: point)
        }
        cd.selectedRoutePoints = []
        UpdateView()
    }
    
    func getNewTargetCoordinate(position: CLLocationCoordinate2D, userBearing: Float, distance: Float)-> CLLocationCoordinate2D{

        let r = 6378140.0
        let latitude1 = position.latitude * (Double.pi/180) // change to radiant
        let longitude1 = position.longitude * (Double.pi/180)
        let brng = Double(userBearing) * (Double.pi/180)

        var latitude2 = asin(sin(latitude1)*cos(Double(distance)/r) + cos(latitude1)*sin(Double(distance)/r)*cos(brng));
        var longitude2 = longitude1 + atan2(sin(brng)*sin(Double(distance)/r)*cos(latitude1),cos(Double(distance)/r)-sin(latitude1)*sin(latitude2));

        latitude2 = latitude2 * (180/Double.pi)// change back to degree
        longitude2 = longitude2 * (180/Double.pi)

        // return target location
        return CLLocationCoordinate2DMake(latitude2, longitude2)
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
        if simPin != nil {return}
        lastLocation = location
        navigate.lastLocation = lastLocation
        var speed = lastLocation!.speed
        speed = (speed >= 0) ? speed * 2.23694 : 0
        lastLocationSpeed =  String(format: "%.1f",speed)
        
        let heading = lastLocation!.course
        if heading >= 0 {lastLocationCourse = String(format: "%.1f",heading)}
        else{lastLocationCourse = "?"}
    }

}

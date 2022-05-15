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

class MapViewModel : NSObject, ObservableObject, CLLocationManagerDelegate, NavCompleteDelegate, NavUpdateReadyDelegate,
                        MapMessageDelegate, StopNavigationDelegate{
    
    
    
    @Published var region:MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.97869683639129, longitude: -120.53599956870863), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @Published var cd = CoreData.shared
    
    @Published var updateView:Bool = false
    var ble:BLEManager?
    var gvm:GlobalViewModel?
    var settings:Settings = Settings()
    var locationManager : CLLocationManager?
    var navigate:NavigateRoute = NavigateRoute()
    var mapInitialized:Bool = false
    
    var lastLocation:CLLocation?
    var lastDeviceHeading:CLHeading?
    var pidController:PID = PID(kp: 1, ki: 1, kd: 0, size: 5)
    
    @Published var lastLocationSpeed:String = ""
    @Published var lastLocationCourse:String = ""
    
    @Published var routePinColor:Color = .red
    @Published var headingString:String = "?"
    
    var blinkPinTimer:Timer?
    var headingTimer:Timer?
    var lastHeadingSent:String = "-1"
    
    var simPin:MapPin?
    var simInitialized:Bool = false
    var simStartLocation:CLLocationCoordinate2D?
    var simulatedLocation:SimulatedLocation?
    
    var droppingCrumbs:Bool = false
    var breadCrumbTimer:Timer?
    var trackRoute:Route?
    var prevPhoneMode:Bool = false;
    
    func initMap(ble:BLEManager, gvm:GlobalViewModel){
        if !mapInitialized{
            checkLocationServicesIsOn()
            mapInitialized = true
            navigate.navCompleteDeletate = self
            self.gvm = gvm
            self.ble = ble
            ble.mapMessageDelegate = self
            gvm.stopNavigationDelegate = self
        }
        UpdateView()
    }
    
    override init(){
        super.init()
        StartHeadingTimer()
    }
}

extension MapViewModel{ // Map Functions
    
    func UpdateMapCenter(){
        if settings.map.trackLocation{
            if let lastLoc = lastLocation{
                if let delta = locationToCenterDelta(){
                    if delta > 0.1{
                        withAnimation(.easeInOut){
                            region.center = lastLoc.coordinate
                        }
                    }
                }
                
            }
        }
    }
    
    func locationToCenterDelta()->Double?{
        if let lastLoc = lastLocation?.coordinate{
            let deltaLat = abs((region.center.latitude - lastLoc.latitude)/region.span.latitudeDelta)
            let deltaLon = abs((region.center.longitude - lastLoc.longitude)/region.span.longitudeDelta)
            if deltaLat > deltaLon{
                return deltaLat
            }
            return deltaLon
        }
        return nil
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
    
    func mapMessage(msg: String) {
//        print("Watch msg: \(msg)")
        if let route = cd.getRouteNamed(name: "Dropped", createIfNotFound: true){
            route.visible = true
//            print("Updating \(route.Name)")
            switch (msg){
            case "FishOn":
                DispatchQueue.main.async {
//                    print("in DispatchQueue")
                    if let loc = self.lastLocation{
//                        print("Adding fish")
                        let pin = self.cd.addMapPin(name: "", location: loc, type: "fish")
                        self.cd.addPinToRoute(route: route, pin: pin)
                        self.UpdateView()
                    }else{
                        print("no valid location found")
                    }
                  }
                break
            case "Shallow":
                DispatchQueue.main.async {
//                    print("Adding shallow")
                    if let loc = self.lastLocation{
                        let pin = self.cd.addMapPin(name: "", location: loc, type: "shallow")
                        self.cd.addPinToRoute(route: route, pin: pin)
                        self.UpdateView()
                    }else{
                        print("no valid location found")
                    }
                  }
                break
            default:
                break
            }
        }
    }
}

extension MapViewModel{ // BreadCrumb Functions
    func StartStopBreadCrumbs(){
        if !droppingCrumbs{
            if let route = cd.getRouteNamed(name: "Track", createIfNotFound: true){
                trackRoute = route
                breadCrumbTimer = Timer.scheduledTimer(withTimeInterval: settings.breadCrumbs.intervalSeconds, repeats: true) { Timer in
                    self.DropACrumbTask()
                }
                droppingCrumbs = true
                route.visible = true
            }
        }else{
            if let timer = breadCrumbTimer{
                timer.invalidate()
            }
            droppingCrumbs = false
        }
        UpdateView()
    }
    
    func DropACrumbTask(){
        var pin:MapPin?
        if let loc = lastLocation{
            if let distToPreviousPin = distToPreviousPin(loc: loc){
                if distToPreviousPin < settings.breadCrumbs.minSeparationMeters{
                    print("Didn't meet min separation distance")
                    return
                }
            }
            pin = cd.addMapPin(name: "", location: loc, type: "track")
        }else{
            print("No valid location")
            return // no valid location
        }
        if let route = trackRoute{
            cd.addPinToRoute(route: route, pin: pin!)
        }
        UpdateView()
    }
    
    func distToPreviousPin(loc:CLLocation) -> Double?{
        if let route = trackRoute{
            if let prevPin = route.routePointsArray.last{
                return prevPin.pointPin!.Location.distance(from: loc)
            }
        }
        return nil
    }
}

extension MapViewModel{ // Navigation Functions
    
    func CalibrateAP(calWith:CalHeadingUsing){
        if settings.simulator.enabled{
            gvm?.apIsCalibrated = true
            return
        }
        var heading = "?"
        if calWith == .currentCourse{
            if lastLocationCourse != "?"{
                heading = lastLocationCourse
            }
        }
        else if let hdg = lastDeviceHeading{
            if hdg.trueHeading >= 0{
                print("Cal heading: \(hdg.trueHeading)")
                heading = String(format: "%.1f",hdg.trueHeading)
            }
        }
        if heading != "?"{
            ble?.sendMessageToAP(data: "\(CMD_CAL_CURRENT_HEADING)\(heading)")
            gvm?.apIsCalibrated = true
        }else{
            gvm?.apIsCalibrated = false
        }
    }
    
    func selectedPinToX()->String{
        if cd.selectedRoutePoints.count > 0{
            if let pin = cd.selectedRoutePoints[0].pointPin{
                let xloc = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
                let dist = pin.Location.distance(from: xloc)
                let bearing = getBearingBetweenTwoPoints1(point1: pin.Location, point2: xloc)
                return "\(distanceString(meters: dist)) \(bearingString(bearing:bearing))"
            }
        }
        return "?"
    }
    
    func locationToX()->String{
        if let loc = lastLocation{
            let xloc = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
            let dist = loc.distance(from: xloc)
            let bearing = getBearingBetweenTwoPoints1(point1: loc, point2: xloc)
            return "\(distanceString(meters: dist)) \(bearingString(bearing: bearing))"
        }
        return "?"

    }
    
    var running:Bool{
//        print("running: \(navigate.running)")
        return navigate.running
    }
    
    func Navigate(route: Route){
        gvm!.navType = .route
        navigate.navUpdateReadyDelegate = self
        var startFromIndex = 0
        if let selectedIndex = route.routePointsArray.firstIndex(where: {$0.selected}){
            startFromIndex = selectedIndex
        }
        if settings.simulator.enabled{
            setSimPin()
            simStartLocation = CLLocationCoordinate2D(latitude: simPin!.latitude, longitude: simPin!.longitude)
            navigate.locationUpdate(location: simPin!.Location)
            simulatedLocation = SimulatedLocation(location: simPin!.Location, headingTarget: 0)
            if !navigate.StartNavigation(route: route, fromIndex: startFromIndex){
                print("Failed to start navigation")
                simPin = nil
                gvm?.navType = .none
                return
            }
        }else{
            if !navigate.StartNavigation(route: route, fromIndex: startFromIndex){
                print("Failed to start navigation")
                gvm?.navType = .none
                return
            }
        }
        StartBlinkTimer()
        UpdateView()
    }
    
    // Stop Nav delegate
    func stopNav() {
        StopNavigation()
    }
    
    func StopNavigation(){
        navigate.CancelNavigation()
        headingString = "?"
    }
    
    func navUpdateReady(newTarget:Bool) {
        if newTarget{
            print("new Target")
            pidController = PID(
                kp: settings.navigation.proportionalTerm,
                ki: settings.navigation.integralTerm,
                kd: settings.navigation.differentialTerm,
                size: settings.navigation.pidLength)
        }
        if gvm!.navType == .none{
            StopNavigation()
            return
        }
        var heading:Double = 0
        if let pin = simPin{
            let headingError = HeadingError(target: navigate.bearingToTarget!, actual: pin.course)
            let newCourseToTarget = FixHeading(heading: simPin!.course - headingError)
            heading = newNavHeading(courseToTarget: newCourseToTarget)
            
            simulatedLocation!.headingTarget = heading
            simPin!.course = simulatedLocation!.heading // this really won't simulate what happens
        }else{
            if let lastLoc = lastLocation{
                let lastLocCourse = lastLoc.course
                let headingError = HeadingError(target: navigate.bearingToTarget!, actual: lastLocCourse)
                let newCourseToTarget = FixHeading(heading: lastLocCourse - headingError)
                heading = newNavHeading(courseToTarget: newCourseToTarget)
                
                print("Sending AP: ht\(heading)")
                ble!.sendMessageToAP(data: "\(CMD_SET_TARGET_HEADING)\(String(format: "%.1f",heading))")
            }
        }
        headingString = String(format: "%.1f",heading)
    }

    // computes a new heading given the current course to target and the desired course to target
    func newNavHeading(courseToTarget:Double)->Double{
        let courseError = HeadingError(target: navigate.desiredBearingToTarget!, actual: courseToTarget)
        pidController.NewError(error: courseError)
        var courseCorrection = pidController.Correction()
//        var courseCorrection = settings.navigation.proportionalTerm * courseError
        
        let maxCorrection = settings.navigation.maxCorrectionDeg
        if courseCorrection! > maxCorrection {courseCorrection = maxCorrection}
        else if courseCorrection! < -maxCorrection {courseCorrection = -maxCorrection}
        let heading = FixHeading(heading: (courseToTarget + courseCorrection!))
        return heading
    }
    
    func UpdateSimulatedLocation(){
        if let pin = simPin{
            simulatedLocation?.update()
            lastLocation = simulatedLocation?.getNewPosition()
            pin.course = simulatedLocation!.heading
//            print(lastLocation)
            pin.latitude = lastLocation!.coordinate.latitude
            pin.longitude = lastLocation!.coordinate.longitude
            UpdateMapCenter()
            //print("UpdateSimulatedLocation lastLocation = \(lastLocation!)")
            navigate.locationUpdate(location: lastLocation!)
            var speed = lastLocation!.speed
            speed = (speed >= 0) ? speed * 2.23694 : 0
            lastLocationSpeed =  String(format: "%.1f",speed)
            
            let course = lastLocation!.course
            if course >= 0 {
                lastLocationCourse = String(format: "%.1f",course)
            }
            else{lastLocationCourse = "?"}
        }
    }
    
    func NavComplete() {
//        print("in NavCompleteDelegate")
        StopBlinkTimer()
        if simPin != nil{
            simPin!.latitude = simStartLocation!.latitude
            simPin!.longitude = simStartLocation!.longitude
//            print("nulling simPin")
            simPin = nil
        }
        if let route = activeRoute(){
            for point in route.routePointsArray{
                point.selected = false
                point.target = false
//                point.pointPin!.type = "fix"
            }
        }
        gvm!.navType = .none
        cd.saveRoutePointData()
        cd.savePinData()
        UpdateView()
    }
    
    func editPinDismissed(){
        UpdateView();
//        print("EditPinView dismissed")
    }
    
    func setSimPin(){
        let route = cd.getRouteNamed(name: "Sim", createIfNotFound: true)
        route?.visible = true
        if route?.routePointsArray.count == 0{
            simPin = cd.addMapPin(name: "fix", latitude: region.center.latitude, longitude: region.center.longitude, type: "sim")
            cd.addPinToRoute(routeName: "Sim", pin: simPin!)
        }else{
            simPin = route?.routePointsArray[0].pointPin
            simPin!.latitude = region.center.latitude
            simPin!.longitude = region.center.longitude
            simPin!.type = "sim"
        }
        simPin!.name = "sim"
        let destPinLocation = cd.getActiveRoute()?.routePointsArray[0].pointPin?.Location
        simPin!.course = getBearingBetweenTwoPoints1(
            point1: CLLocation(latitude: simPin!.latitude, longitude: simPin!.longitude),
            point2: destPinLocation!)
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
        if let selectedPoint = cd.selectedRoutePoint(route: route){
            cd.addPinToRoute(routeName: route.Name, pin: pin!, atIndex: Int(selectedPoint.index))
        }else{
            cd.addPinToRoute(routeName: route.Name, pin: pin!)
        }
        UpdateView()
    }
    
    func DeleteSelectedPoints(){
        for point in cd.selectedRoutePoints{
            cd.deleteRoutePoint(routePoint: point)
        }
        cd.selectedRoutePoints = []
        UpdateView()
    }
    
    
}

extension MapViewModel{ // Location calls
    func sendHeadingToAp(){
        if (settings.navigation.phoneHeadingMode){
            if let heading = lastDeviceHeading{
                let strHeading = String(format:"%.1f",heading.trueHeading)
                if strHeading != lastHeadingSent{
                    lastHeadingSent = strHeading
                    ble!.sendMessageToAP(data: "\(CMD_SET_PHONE_HEADING)\(strHeading)")
                    if (prevPhoneMode==false){
                        ble!.sendMessageToAP(data: "\(CMD_SET_TARGET_HEADING)\(strHeading)")
                        ble!.sendMessageToAP(data: "\(CMD_LOCK)")
                    }
                }
            }
            prevPhoneMode = true
        }else if prevPhoneMode==true{
            ble!.sendMessageToAP(data: "\(CMD_SET_PHONE_HEADING)-1")
            prevPhoneMode = false;
        }
    }
    
    func StartHeadingTimer(){
        headingTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { Timer in
            self.sendHeadingToAp()
        }
    }
    
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
                locationManager.startUpdatingHeading()
                locationManager.allowsBackgroundLocationUpdates = true
            }
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("in locationManager - didUpdateLocations")
        guard let location = locations.last else {return}
        if settings.simulator.enabled {return}
        lastLocation = location
        if gvm!.compassCalLocationDelegate != nil{
            gvm!.compassCalLocationDelegate!.compassCalLocation(location: location)
        }
        UpdateMapCenter()
//        print("calling navigate.locationUpdate")
        navigate.locationUpdate(location: lastLocation!)
        var speed = lastLocation!.speed
        speed = (speed >= 0) ? speed * 2.23694 : 0
        lastLocationSpeed =  String(format: "%.1f",speed)
        
        let heading = lastLocation!.course
        if heading >= 0 {lastLocationCourse = String(format: "%.1f",heading)}
        else{lastLocationCourse = "?"}
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateHeading newHeading: CLHeading){
//        print("newHeading: \(newHeading.trueHeading)")
        lastDeviceHeading = newHeading
        if gvm!.compassCalHeadingDelegate != nil{
            gvm!.compassCalHeadingDelegate!.compassCalHeading(heading: newHeading)
        }
    }
}

//
//  NavigateRoute.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/31/22.
//

import SwiftUI
import CoreLocation


class NavigateRoute : ObservableObject{
    var navUpdateReadyDelegate:NavUpdateReadyDelegate?
    var settings:Settings = Settings()
    var navCompleteDeletate:NavCompleteDelegate?
    var route:Route?
    var navTimer:Timer?
    var targetPin:MapPin?
    var routeIndex:Int = -1
    var targetPinLocation:CLLocation?
    var currentLocation:CLLocation?
    var distToTarget:Double?
    var desiredBearingToTarget:Double?
    var bearingToTarget:Double?
    var lastLocation:CLLocation?
    var closeToTarget:Bool=false
//    var arrivalZone:Double = 30 // assume if within this distance (m), we're at the target
    @Published var running:Bool = false
    @Published var distToTargetString:String="?"
    @Published var bearingToTargetString:String="?"
    @Published var desiredBearingToTargetString:String = "?"
    
    init(){
    }
    
    func StartNavigation(route:Route, fromIndex:Int = 0) -> Bool{
//        arrivalZone = settings.navigation.arrivalZoneMeters
//        print("arrivalZone set to \(arrivalZone)m")
        closeToTarget = false
        self.route = route
        guard let lastLoc = lastLocation else {
            print("Invalid lastLoc")
            return false}
        guard route.routePointsArray.count > 0 else {
            print("No points in the route array")
            return false}
        routeIndex = fromIndex
        targetPin = route.routePointsArray[routeIndex].pointPin
        // skip over any shallow points
        while (targetPin!.unwrappedType == "shallow"){
            routeIndex = routeIndex + 1
            if routeIndex == route.routePointsArray.count{
                return false
            }
            targetPin = route.routePointsArray[routeIndex].pointPin
        }
        //print("StartNavigation lastLoc \(lastLoc)")
        route.routePointsArray[routeIndex].setTarget(enabled: true)
        targetPinLocation = CLLocation(latitude: targetPin!.latitude, longitude: targetPin!.longitude)
        desiredBearingToTarget = getBearingBetweenTwoPoints1(point1: lastLoc, point2: targetPinLocation!)
        desiredBearingToTargetString = bearingString(bearing: desiredBearingToTarget!)
        running = true
        startNavTimer(interval: settings.navigation.intervalSeconds)
        navigateRoute()
        return true
    }
    
    private func navigateRoute(){
        guard let lastLoc = lastLocation else {
            print("Invalid lastLoc")
            return}
        print("nav timer interval \(settings.navigation.intervalSeconds)")
        setTargetStats(lastLoc: lastLoc)
        
        if !closeToTarget{
            // change sample time if setting has changed
            startNavTimer(interval: settings.navigation.intervalSeconds)
        }
        if distToTarget! < settings.navigation.arrivalZoneMeters{
            print("distToTarget: \(distToTarget!)m  arrivalZone: \(settings.navigation.arrivalZoneFeet)ft")
            if routeIndex == route!.routePointsArray.count - 1{
                route!.routePointsArray.last!.target = false
                CancelNavigation()
                return
            }
            // setup for the next point
            closeToTarget = false
            startNavTimer(interval: settings.navigation.intervalSeconds)
            route!.routePointsArray[routeIndex].target = false
            routeIndex = routeIndex + 1
            route!.routePointsArray[routeIndex].target = true
            let fromPinLoc = targetPinLocation // save it to compute the desired heading
            targetPin = route!.routePointsArray[routeIndex].pointPin
            targetPinLocation = targetPin!.Location
            // calculate the bearing to the target from the previous pin
            desiredBearingToTarget = getBearingBetweenTwoPoints1(point1: fromPinLoc!, point2: targetPinLocation!)
            desiredBearingToTargetString = bearingString(bearing: desiredBearingToTarget!)
            setTargetStats(lastLoc: lastLoc)
            //print("New Target")
        }
        if let navupdate = navUpdateReadyDelegate{
            navupdate.navUpdateReady()
        }
    }
    
    private func setTargetStats(lastLoc:CLLocation){
        distToTarget = lastLoc.distance(from: targetPinLocation!)
        distToTargetString = distanceString(meters: distToTarget!)
        bearingToTarget = getBearingBetweenTwoPoints1(point1: lastLoc, point2: targetPinLocation!)
        bearingToTargetString = bearingString(bearing: bearingToTarget!)
        adjustTimerInterval()
    }
    
    func adjustTimerInterval(){
        guard let timer = navTimer else {return}
        if timer.timeInterval == 1 {return}
        if let speed = lastLocation?.speed{
            let test = (speed * 20)/distToTarget!
            //print("timerTest \(test)")
            if test > 1{
                closeToTarget = true
                startNavTimer(interval: 1)
            }
        }
    }
    
//    func setNavTimer(interval:Double){
//        if navTimer!.timeInterval == interval {return}
//        navTimer!.invalidate()
//        startNavTimer(interval: interval)
//    }
    
    func startNavTimer(interval:Double){
        if let timer = navTimer{
            if timer.timeInterval == interval{return}
            timer.invalidate()
        }
        navTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { Timer in
            self.navigateRoute()
        }
    }
    
    func CancelNavigation(){
        print("in CancelNavigation")
        if let killTimer = navTimer{
            killTimer.invalidate()
        }
        running = false
        if let navComplete = navCompleteDeletate{
            navComplete.NavComplete()
        }
    }
    
    
}

//
//  NavigateRoute.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/31/22.
//

import SwiftUI
import CoreLocation

protocol CurrentLocationDelegate{
    func currentLocation(location:CLLocation)
}
class NavigateRoute : ObservableObject, CurrentLocationDelegate{
    func currentLocation(location: CLLocation) {
        lastLocation = location
    }
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
    var arrivalZone:Double = 30 // assume if within this distance (m), we're at the target
    @Published var running:Bool = false
    @Published var distToTargetString:String="?"
    @Published var bearingToTargetString:String="?"
    @Published var desiredBearingToTargetString:String = "?"
    
    init(){
    }
    
    func StartNavigation(route:Route, fromIndex:Int = 0) -> Bool{
        self.route = route
        guard let lastLoc = lastLocation else {
            print("Invalid lastLoc")
            return false}
        guard route.routePointsArray.count > 0 else {
            print("No points in the route array")
            return false}
        routeIndex = fromIndex
        targetPin = route.routePointsArray[routeIndex].pointPin
        route.routePointsArray[routeIndex].setTarget(enabled: true)
        targetPinLocation = CLLocation(latitude: targetPin!.latitude, longitude: targetPin!.longitude)
        desiredBearingToTarget = getBearingBetweenTwoPoints1(point1: lastLoc, point2: targetPinLocation!)
        desiredBearingToTargetString = bearingString(bearing: desiredBearingToTarget!)
        running = true
        startNavTimer(interval: 10)
        navigateRoute()
        return true
    }
    
    private func navigateRoute(){
        guard let lastLoc = lastLocation else {
            print("Invalid lastLoc")
            return}
        setTargetStats(lastLoc: lastLoc)
        if distToTarget! < arrivalZone{
            if routeIndex == route!.routePointsArray.count - 1{
                route!.routePointsArray.last!.target = false
                CancelNavigation()
                return
            }
            // head to the next point
            setNavTimer(interval: 10)
            route!.routePointsArray[routeIndex].target = false
            routeIndex = routeIndex + 1
            route!.routePointsArray[routeIndex].target = true
            let fromPinLoc = targetPinLocation // save it to compute the desired heading
            targetPin = route!.routePointsArray[routeIndex].pointPin
            targetPinLocation = targetPin!.Location
            desiredBearingToTarget = getBearingBetweenTwoPoints1(point1: fromPinLoc!, point2: targetPinLocation!)
            desiredBearingToTargetString = bearingString(bearing: desiredBearingToTarget!)
            setTargetStats(lastLoc: lastLoc)
            print("New Target")
        }
    }
    
    private func setTargetStats(lastLoc:CLLocation){
        distToTarget = lastLoc.distance(from: targetPinLocation!)
        distToTargetString = distanceString(meters: distToTarget!)
        bearingToTarget = getBearingBetweenTwoPoints1(point1: lastLoc, point2: targetPinLocation!)
        bearingToTargetString = bearingString(bearing: bearingToTarget!)
        checkTimerInterval()
    }
    
    func checkTimerInterval(){
        guard let timer = navTimer else {return}
        if timer.timeInterval == 1 {return}
        if let speed = lastLocation?.speed{
            let test = (speed * 10)/distToTarget!
            print("timerTest \(test)")
            if test > 1{
                setNavTimer(interval: 1)
            }
        }
    }
    
    func setNavTimer(interval:Double){
        if navTimer!.timeInterval == interval {return}
        navTimer!.invalidate()
        startNavTimer(interval: interval)
    }
    
    func startNavTimer(interval:Double){
        navTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { Timer in
            self.navigateRoute()
        }
    }
    
    func CancelNavigation(){
        if let killTimer = navTimer{
            killTimer.invalidate()
        }
        running = false
        if let navComplete = navCompleteDeletate{
            navComplete.NavComplete()
        }
    }
    
    func distanceString(meters:Double) -> String{
        let miles = meters/1609.34
        if miles < 0.18 { // 999ft
            let ft = miles * 5280
            return "\(String(format: "%.0f",ft))ft"
        }
        return "\(String(format: "%.1f",miles))mi"
    }
    
    func bearingString(bearing:Double) -> String{
        return "\(String(format: "%.1f",bearing))deg"
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }

    func getBearingBetweenTwoPoints1(point1 : CLLocation, point2 : CLLocation) -> Double {

        let lat1 = degreesToRadians(degrees: point1.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: point1.coordinate.longitude)

        let lat2 = degreesToRadians(degrees: point2.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: point2.coordinate.longitude)

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        var bearingInDegrees = radiansToDegrees(radians: radiansBearing)
        if bearingInDegrees <= 0 {
            bearingInDegrees = bearingInDegrees + 360
        }
        return bearingInDegrees
    }
}

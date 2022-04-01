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
    @Published var running:Bool = false
    @Published var distToTargetString:String="?"
    @Published var bearingToTargetString:String="?"
    
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
        distToTarget = lastLoc.distance(from: targetPinLocation!)
        distToTargetString = distanceString(meters: distToTarget!)
        desiredBearingToTarget = getBearingBetweenTwoPoints1(point1: lastLoc, point2: targetPinLocation!)
        running = true
        navigateRoute()
        navTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { Timer in
            self.navigateRoute()
        }
        return true
    }
    
    private func navigateRoute(){
        guard let lastLoc = lastLocation else {
            print("Invalid lastLoc")
            return}
        distToTarget = lastLoc.distance(from: targetPinLocation!)
        print("navigateRoute distToTarget = \(distToTarget!)")
        distToTargetString = distanceString(meters: distToTarget!)
        bearingToTarget = getBearingBetweenTwoPoints1(point1: lastLoc, point2: targetPinLocation!)
        bearingToTargetString = bearingString(bearing: bearingToTarget!)
        print("Target.. Dist: \(distToTargetString), Bearing: \(bearingToTargetString)")
        if distToTarget! < 30{
            if routeIndex == route!.routePointsArray.count - 1{
                route!.routePointsArray.last!.target = false
                CancelNavigation()
                return
            }
            // head to the next point
            route!.routePointsArray[routeIndex].target = false
            routeIndex = routeIndex + 1
            route!.routePointsArray[routeIndex].target = true
            let fromPinLoc = targetPinLocation // save it to compute the desired heading
            targetPin = route!.routePointsArray[routeIndex].pointPin
            targetPinLocation = targetPin!.Location
            desiredBearingToTarget = getBearingBetweenTwoPoints1(point1: fromPinLoc!, point2: targetPinLocation!)
            bearingToTarget = getBearingBetweenTwoPoints1(point1: lastLoc, point2: targetPinLocation!)
            bearingToTargetString = bearingString(bearing: bearingToTarget!)
            distToTarget = lastLoc.distance(from: targetPinLocation!)
            distToTargetString = distanceString(meters: distToTarget!)
            print("New Target")
        }
    }
    
    func CancelNavigation(){
        if let killTimer = navTimer{
            killTimer.invalidate()
            running = false
        }
    }
    
    func distanceString(meters:Double) -> String{
        let miles = meters/1609.34
        print("miles = \(miles)")
        if miles < 0.18 {
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

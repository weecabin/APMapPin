//
//  NavigateRoute.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/31/22.
//

import SwiftUI
import CoreLocation


class NavigateRoute : ObservableObject{
    var cd = CoreData.shared
    var navUpdateReadyDelegate:NavUpdateReadyDelegate?
    var navCompleteDeletate:NavCompleteDelegate?
    var desiredBearingToTarget:Double?
    var bearingToTarget:Double?
    
    @Published var running:Bool = false
    @Published var distToTargetString:String="?"
    @Published var bearingToTargetString:String="?"
    @Published var desiredBearingToTargetString:String = "?"
    @Published var timeToTargetPin:String="?"
    @Published var timeToEnd:String="?"
    
    private var distToTarget:Double?
    private var targetPinLocation:CLLocation?
    private var navTimer:Timer?
    private var targetPin:MapPin?
    private var routeIndex:Int = -1
    private var startIndex:Int = 0
    private var endOfRoute:Bool = false
    private var settings:Settings = Settings()
    private var route:Route?
    private var lastLocation:CLLocation?
    private var closeToTarget:Bool=false
    private let epsilon:Double = 0.0000001
    private var timerCounter:Double = 0
    private var timerCounterLimit:Double = 1
    private var newTargetCourse:Bool = true
    
    init(){
    }
    func StartNavigation(route:Route, fromIndex:Int = 0) -> Bool{
        endOfRoute = false
        startIndex = fromIndex
        if settings.navigation.reverseRoute{
            if startIndex == 0{
                startIndex = route.routePointsArray.count-1
            }
            if startIndex==0{
                endOfRoute = true
            }
        }
        else{
            if startIndex == route.routePointsArray.count-1{
                endOfRoute = true
            }
        }
        
        newTargetCourse = true
        timerCounter = 0
        closeToTarget = false
        self.route = route
        guard let lastLoc = lastLocation else {
            print("Invalid lastLoc")
            return false}
        guard route.routePointsArray.count > 0 else {
            print("No points in the route array")
            return false}
        routeIndex = startIndex
        targetPin = route.routePointsArray[routeIndex].pointPin

        route.routePointsArray[routeIndex].setTarget(enabled: true)
        targetPinLocation = CLLocation(latitude: targetPin!.latitude, longitude: targetPin!.longitude)
        desiredBearingToTarget = getBearingBetweenTwoPoints1(point1: lastLoc, point2: targetPinLocation!)
        desiredBearingToTargetString = bearingString(bearing: desiredBearingToTarget!)
        running = true
        startNavTimer(interval: settings.navigation.intervalSeconds)
        setTargetStats(lastLoc: lastLoc)
        navigateRoute()
        return true
    }
    
    private func nextRouteIndex(){
        if endOfRoute // we're looping
        {
            if settings.navigation.reverseRoute
            {
                if startIndex == 0{
                    routeIndex = route!.routePointsArray.count-1
                }else{
                    routeIndex = startIndex
                }
                
            }
            else
            {
                routeIndex = startIndex
            }
            endOfRoute = false
        }
        else
        {
            if settings.navigation.reverseRoute
            {
                routeIndex -= 1
                if routeIndex == 0
                {
                    endOfRoute = true
                }
            }
            else
            {
                routeIndex += 1
                if routeIndex == route!.routePointsArray.count-1
                {
                    endOfRoute = true
                }
            }
        }
    }
    
    private func navigateRoute(){
//        print("in navigateRoute")
        guard let lastLoc = lastLocation else {
            print("Invalid lastLoc")
            return}

        //print("nav timer interval \(settings.navigation.intervalSeconds)")
        setTargetStats(lastLoc: lastLoc)
        
        if !closeToTarget{
            // change sample time if setting has changed
            startNavTimer(interval: settings.navigation.intervalSeconds)
        }
        
        if distToTarget! < settings.navigation.arrivalZoneMeters{
            print("inside arrival zone")
            if endOfRoute{
                if !settings.navigation.loopRoute{
                    route!.routePointsArray.last!.target = false
                    CancelNavigation()
                    return
                }
            }
            // setup for the next point
            newTargetCourse = true
            route!.routePointsArray[routeIndex].target = false
            // If we're at the end of the route, we're looping,
            // so set the destination to the beginning of the route
            nextRouteIndex()
            route!.routePointsArray[routeIndex].target = true
            let fromPinLoc = targetPinLocation // save it to compute the desired heading
            targetPin = route!.routePointsArray[routeIndex].pointPin
            targetPinLocation = targetPin!.Location
            // calculate the bearing to the target from the previous pin
            desiredBearingToTarget = getBearingBetweenTwoPoints1(point1: fromPinLoc!, point2: targetPinLocation!)
            desiredBearingToTargetString = bearingString(bearing: desiredBearingToTarget!)
            setTargetStats(lastLoc: lastLoc)
            //print("New Target")
            closeToTarget = false
            startNavTimer(interval: settings.navigation.intervalSeconds)
        }
        if let navupdate = navUpdateReadyDelegate{
            navupdate.navUpdateReady(newTarget: newTargetCourse)
            newTargetCourse = false
        }
    }
    
    private func setTargetStats(lastLoc:CLLocation){
//        print("in setTargetStats")
        distToTarget = lastLoc.distance(from: targetPinLocation!)
        distToTargetString = distanceString(meters: distToTarget!)
        bearingToTarget = getBearingBetweenTwoPoints1(point1: lastLoc, point2: targetPinLocation!)
        bearingToTargetString = bearingString(bearing: bearingToTarget!)
        if lastLoc.speed != 0{
            let timeToPin = distToTarget!/lastLoc.speed
            timeToTargetPin = timeString(seconds: Int(timeToPin))
        }else{
            timeToTargetPin = "?"
        }
        updateTimeToEnd(lastLoc: lastLoc)
        reduceTimerInterval()
    }
    
    func updateTimeToEnd(lastLoc:CLLocation){
//        print("in updateTimeToEnd")
        var distanceAfterTarget:Double = 0
        var lastIndex = route!.routePointsArray.count - 1
        if let index = route!.routePointsArray.firstIndex(where: {$0.selected}){
            lastIndex = index
        }
        if routeIndex < lastIndex{
            for index in (routeIndex+1...lastIndex){
                let rp = route!.routePointsArray[index]
                if let dist = cd.distanceTo(route: route!, routePoint: rp){
                    distanceAfterTarget = distanceAfterTarget + dist
                }
            }
        }
        let timeToPin = distToTarget!/lastLoc.speed
//        print("dist: \(distToTarget!) time: \(timeToPin)")
        if lastLoc.speed != 0 {
            let targetToEndTime = timeToPin + distanceAfterTarget/lastLoc.speed
            timeToEnd = distanceAfterTarget > 0 ? timeString(seconds: Int(targetToEndTime)) : ""
        }else{
            timeToEnd = "?"
        }
    }
    
    func reduceTimerInterval(){
        if settings.navigation.timerMode{
            guard let timer = navTimer else {return}
            if timer.timeInterval == 1 {return}
        }else{
            if timerCounter == 1 {return}
        }
        if let speed = lastLocation?.speed{
            let test = (speed * 20)/distToTarget!
//            print("timerTest \(test)")
            if test > 1 && !closeToTarget{
                closeToTarget = true
                print("setting timer interval to 1")
                if settings.navigation.timerMode{
                    startNavTimer(interval: 1)
                }else{
                    timerCounterLimit = 1}
            }
        }
        
    }
    
    func testCloseToTarget(speed:Double)->Bool{
        let sampleDistance = speed * settings.navigation.intervalSeconds
        if (sampleDistance * 2) > (distToTarget!){
            return true
        }
        return false
    }
    
    func startNavTimer(interval:Double){
//        print("in startNavTimer \(interval)")
        if settings.navigation.timerMode{
            if let timer = navTimer{
    //            print("invalidating existing timer")
                if timer.timeInterval == interval{
    //                print("exiting startNavTimer")
                    return}
                timer.invalidate()
            }
            navTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { Timer in
                self.navigateRoute()
            }
        }else{
            timerCounterLimit = interval}
    }
    
    func CancelNavigation(){
//        print("in CancelNavigation")
        if let killTimer = navTimer{
            killTimer.invalidate()
            navTimer = nil
        }
        running = false
        if let navComplete = navCompleteDeletate{
            navComplete.NavComplete()
        }
    }
    
    func locationUpdate(location:CLLocation){
        lastLocation = location
        if running{
            if !settings.navigation.timerMode{
                timerCounter = timerCounter + 1
                if timerCounter >= timerCounterLimit{
                    timerCounter = 0
                    navigateRoute()
                }
            }
        }
    }
}

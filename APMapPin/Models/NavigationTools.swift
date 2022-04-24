//
//  NavigationTools.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/21/22.
//

import Foundation
import MapKit

func getBearingBetweenTwoPoints1(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double{
    return getBearingBetweenTwoPoints1(
        point1: CLLocation(latitude: point1.latitude, longitude: point1.longitude),
        point2: CLLocation(latitude: point2.latitude, longitude: point2.longitude))
}

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

class SimulatedLocation{
    var settings:Settings = Settings()
    var prevLocation:CLLocation?
    var location:CLLocation?
    private var currentHeading:Double = 0
    var headingTarget:Double

    let metersPerLatitude:Double = 111111.111
    var initialized:Bool = false
    var heading:Double{
        get{
            currentHeading
        }
        set(value){
            headingTarget = value
        }
    }
    
    init(location:CLLocation, headingTarget:Double){
        self.location = location
        self.prevLocation = location
        self.headingTarget = headingTarget
        self.currentHeading = headingTarget
    }
    
    func newHeading(newHeading:Double){
        headingTarget = newHeading
    }
    
    func update(){
        let turnRate = settings.simulator.turnRate
        let headingDelta = HeadingError(target: headingTarget, actual: currentHeading)
        if abs(headingDelta) > turnRate{
            currentHeading = FixHeading(heading: headingDelta>0 ? currentHeading - turnRate : currentHeading + turnRate)
        }else{
            currentHeading = headingTarget
        }
//        print(currentHeading)
    }
    
    func getNewPosition()->CLLocation?{
        prevLocation = location
        if let prevCoord = prevLocation?.coordinate{
            let now = Date.now
            let interval:Double = now.timeIntervalSince(prevLocation!.timestamp)
            let speedInMetersPerSec = settings.simulator.speed / 2.23694 // converting mph to m/s
            let distanceTraveled = Float(speedInMetersPerSec * interval)
            let windPush:Double = (Double(distanceTraveled) * settings.simulator.windPercent * 0.01) / metersPerLatitude// for now wind is always from the south
//            print("distance: \(distanceTraveled) windPush: \(windPush)")
            // uses heading and wind to calculate the new location
            let newCoord = getNewTargetCoordinate(
                position: CLLocationCoordinate2D(latitude: prevCoord.latitude + windPush, longitude: prevCoord.longitude),
                userBearing: Float(currentHeading),
                distance: distanceTraveled)
            let newCourse = getBearingBetweenTwoPoints1(point1: prevCoord, point2: newCoord)
            location = CLLocation(coordinate: newCoord, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: newCourse, speed: speedInMetersPerSec, timestamp: Date.now)
            return location
        }
        return nil
    }
}


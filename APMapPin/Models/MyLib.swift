//
//  MyLib.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/2/22.
//

import Foundation
import MapKit

enum NavType{
    case none
    case route
}

func FixHeading(heading:Double) -> Double{
    var newheading = heading
    while(newheading<0){newheading = newheading + 360}
    while(newheading>360){newheading = newheading - 360}
    return newheading;
}

func HeadingError(target:Double, actual:Double) -> Double
{
    let target = FixHeading(heading: target)
    let actual = FixHeading(heading: actual)
    var  diff = actual-target
    if (diff>180){diff=diff-360}
    if (diff < -180) {diff=diff+360}
    return diff;
}

/*
 Returns a substring of a source string
 src
 The string to search
 
 sub
 The substring to find
 
 offset
 characters to offset from the sub identifying the start of the return string
 
 returnLen
 The number of characters to return from the beginning of sub+offset
 
 occurance
 The occurance count of the substring
 */
func MySubString(src:String, sub:String, returnLen:Int, occurance:Int=1, offset:Int=0, debug:Bool=false)->String{
    
    var instanceCount = occurance
    let subLen = sub.count
    
    if debug {print("looking for: " + sub + " in: " + src)}
    
    if !src.contains(sub){
        if debug{
            print("Early Exit")
        }
        return ""
        }
    for index in 0...src.count-subLen{
        var start = src.index(src.startIndex, offsetBy: index)
        var end = src.index(src.startIndex, offsetBy: index+subLen)
        var range = start..<end
        let test = String(src[range])
        if debug {print(test)}
        
        if  test == sub{
            if instanceCount==1{
                start = src.index(src.startIndex, offsetBy: index + offset)
                if debug{print("found it")}
                var endOffset = index+offset+returnLen
                if endOffset > src.count-1{endOffset = src.count}
                end = src.index(src.startIndex, offsetBy: endOffset)
                if start > end {return ""}
                range = start..<end
                let temp = String(src[range]).split(separator: "\n")
                return String(temp[0])
            }
            instanceCount=instanceCount-1
        }
    }
    return ""
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

func timeString(seconds:Int) -> String{
    let time = secondsToHoursMinutesSeconds(seconds)
    let hours:String = time.0>0 ? "\(time.0)h" : ""
    let mins:String = time.1>0 ? "\(time.1)m" : ""
    let secs:String = "\(time.2)s"
    return "\(hours)\(mins)\(secs)"
}

func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }

func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }

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

class SimulatePosition{
    var settings:Settings = Settings()
    var prevLocation:CLLocation?
    var location:CLLocation?
    var heading:Double
    var windInfluence:Double
    let feetPerLatitude:Double = 364000
    
    init(location:CLLocation, heading:Double, windPercent:Double = 0){
        self.location = location
        self.prevLocation = location
        windInfluence = windPercent
        self.heading = heading
    }
    
    func getNewPosition()->CLLocation?{
        prevLocation = location
        if let prevCoord = prevLocation?.coordinate{
            let now = Date.now
            let interval = now.timeIntervalSince(prevLocation!.timestamp)
            let speedInMetersPerSec = settings.simulator.speed / 2.23694 // converting mph to m/s
            let distanceTraveled = Float(speedInMetersPerSec * interval)
            let windPush:Double = windInfluence * interval / feetPerLatitude // for now wind is always from the south
            // uses heading and wind to calculate the new location
            let newCoord = getNewTargetCoordinate(
                position: CLLocationCoordinate2D(latitude: prevCoord.latitude + windPush, longitude: prevCoord.longitude),
                userBearing: Float(heading),
                distance: distanceTraveled)
            let newCourse = getBearingBetweenTwoPoints1(point1: prevCoord, point2: newCoord)
            let newLocation = CLLocation(coordinate: newCoord, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: newCourse, speed: speedInMetersPerSec, timestamp: Date.now)
            return newLocation
        }
        return nil
    }
}

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
    case singlePin
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

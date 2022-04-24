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

enum CalHeadingUsing{
    case currentCourse
    case deviceOrientation
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

func HeadingString(heading:Double) -> String{
    return "\(String(format: "%.1f",heading))true"
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

class PID{
    var kp:Double
    var ki:Double
    var kd:Double
    var size:Int
    private var targetValue:Double?
    private var errorValues:[Double] = []
    
    init(kp:Double, ki:Double, kd:Double, size:Int){
        self.kp = kp
        self.ki = ki
        self.kd = kd
        self.size = size
    }
    
    func SetTargetValue(target:Double){
        targetValue = target
        errorValues = []
    }
    
    func NewValue(value:Double){
        if let target = targetValue{
            errorValues.append(value - target)
            if errorValues.count > size{
                errorValues.remove(at: 0)
            }
        }
        
    }
    
    func NewError(error:Double){
        targetValue = 0 // this satisfies the test for a valid target in Correction()
        errorValues.append(error)
        if errorValues.count > size{
            errorValues.remove(at: 0)
        }
//        print(errorValues)
    }
    
    func Correction()->Double?{
        guard (errorValues.count>0 && targetValue != nil) else {return nil}
        var retValue = errorValues.last! * kp
        if ki != 0{
            var integralValue:Double = 0
            for value in errorValues{
                integralValue = integralValue + value * ki
            }
            retValue = retValue + integralValue
        }
        if kd != 0{
            if errorValues.count > 1{
                let lastIndex = errorValues.count - 1
                retValue = retValue + (errorValues[lastIndex] - errorValues[lastIndex-1])*kd
            }
        }
//        print("Correction: \(retValue)")
        return retValue
    }
}


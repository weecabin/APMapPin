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

//with a msg like this...
//msg = "hd=56.5,55.5,60.5,59"
//names is an array of strings defining each parameter
//returns a dictionary of values
func convert(msg:String,names:[String])->[String:Double]{
  let vals = msg.components(separatedBy: "=")[1].components(separatedBy: ",")
  var ret:[String:Double]=[:]
  var i = 0
  for val in vals{
    ret[names[i]]=Double(val)
    i += 1
  }
  return ret
}

extension StringProtocol  {
    func substring<S: StringProtocol>(from start: S, options: String.CompareOptions = []) -> SubSequence? {
        guard let lower = range(of: start, options: options)?.upperBound
        else { return nil }
        return self[lower...]
    }
    func substring<S: StringProtocol>(through end: S, options: String.CompareOptions = []) -> SubSequence? {
        guard let upper = range(of: end, options: options)?.upperBound
        else { return nil }
        return self[..<upper]
    }
    func substring<S: StringProtocol>(upTo end: S, options: String.CompareOptions = []) -> SubSequence? {
        guard let upper = range(of: end, options: options)?.lowerBound
        else { return nil }
        return self[..<upper]
    }
    func substring<S: StringProtocol, T: StringProtocol>(from start: S, upTo end: T, options: String.CompareOptions = []) -> SubSequence? {
        guard let lower = range(of: start, options: options)?.upperBound,
            let upper = self[lower...].range(of: end, options: options)?.lowerBound
        else { return nil }
        return self[lower..<upper]
    }
    func substring<S: StringProtocol, T: StringProtocol>(from start: S, through end: T, options: String.CompareOptions = []) -> SubSequence? {
        guard let lower = range(of: start, options: options)?.upperBound,
            let upper = self[lower...].range(of: end, options: options)?.upperBound
        else { return nil }
        return self[lower..<upper]
    }
}

struct LatLon{
    var lat:Double
    var lon:Double
}
struct GpxRoute{
    var Name:String = ""
    var latLon:[LatLon] = []
    func print(){
        Swift.print(Name)
        for ll in latLon{
            Swift.print(ll)
        }
    }
}

func getLatLon(gpxStr:String)->GpxRoute
{
    var rr:GpxRoute = GpxRoute()
    
    let name = gpxStr.substring(from: "<rte><name>",upTo:"</name>")
    rr.Name = String(name ?? "error")
    
    var latlon = gpxStr.substring(from: "</time>")
    while let ll = latlon?.substring(from: "<rtept"){
        let lat = ll.substring(from: " lat=\"", upTo: "\"")
        let lon = ll.substring(from: "lon=\"", upTo: "\"")
        if (lat != nil && lon != nil)
        {
            rr.latLon.append( LatLon(lat:Double(lat!)!,lon:Double(lon!)!))
        }
        else
        {
            break
        }
        latlon = ll
    }
    return rr
}

func printTimeStamp(prefix:String,format:String = "yyyy-MM-dd HH:mm:ss.SSS"){
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = format
    let dateString = formatter.string(from: date)
    print(prefix,dateString)
}

let CMD_LOCK = Character(UnicodeScalar(1))
let CMD_DELTA_LEFT = Character(UnicodeScalar(2))
let CMD_DELTA_RIGHT = Character(UnicodeScalar(3))
let CMD_CIRCLE_LEFT = Character(UnicodeScalar(4))
let CMD_CIRCLE_RIGHT = Character(UnicodeScalar(5))
let CMD_STOP_ACTUATOR = Character(UnicodeScalar(6))
let CMD_START_ACTUATOR = Character(UnicodeScalar(7))
let CMD_MOVE_ACTUATOR_RELATIVE = Character(UnicodeScalar(8))

let CMD_CAL_CURRENT_HEADING = Character(UnicodeScalar(21))

let CMD_SET_TARGET_HEADING = Character(UnicodeScalar(30))
let CMD_SET_PHONE_HEADING = Character(UnicodeScalar(31))
let CMD_SET_ACTUATOR_OFFSET = Character(UnicodeScalar(32))
let CMD_SET_ACTUATOR_POSITION = Character(UnicodeScalar(34))
let CMD_SET_MOVE_NULL_ZONE = Character(UnicodeScalar(35))
let CMD_SET_ACTUATOR_LIMIT = Character(UnicodeScalar(36))
let CMD_SET_PID_INTERVAL = Character(UnicodeScalar(37))
let CMD_SET_DRIVE_PROPORTIONAL = Character(UnicodeScalar(39))
let CMD_SET_DRIVE_INCREMENTAL = Character(UnicodeScalar(40))
let CMD_SET_PID_COEFFICIENTS = Character(UnicodeScalar(41))
let CMD_SET_SOFT_STOP = Character(UnicodeScalar(42))
let CMD_SET_CIRCLING_PARAMETERS = Character(UnicodeScalar(43))

let CMD_GET_ACTUATOR_OFFSET = Character(UnicodeScalar(52))
let CMD_GET_ACTUATOR_POSITION = Character(UnicodeScalar(53))
let CMD_GET_CURRENT_HEADING = Character(UnicodeScalar(54))
let CMD_GET_CURRENT_HEADING_TARGET = Character(UnicodeScalar(55))
let CMD_GET_PLOT_DATA = Character(UnicodeScalar(56))

let CMD_WRITE_CONFIG_TO_EEPROM = Character(UnicodeScalar(70))


//
//  MyLib.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/2/22.
//

import Foundation

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

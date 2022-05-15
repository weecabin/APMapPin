//
//  CoreDataExtensions.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import Foundation
import CoreLocation

extension MapPin : Comparable{
    public static func < (lhs: MapPin, rhs: MapPin) -> Bool {
        lhs.Name < rhs.Name
    }
    
    public var Name:String{
        name ?? "Unknown name"
    }
    
    public var unwrappedType:String{
        type ?? "type?"
    }
    
    public var routePointsArray: [RoutePoint]{
        let pinPointSet = pinPoints as? Set<RoutePoint> ?? []
        return pinPointSet.sorted()
    }
    
    public var Location:CLLocation{
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    public var altInFeet:Double{
        get{
            return altitude * 3.28084
        }
        set(altInFt){
            altitude = altInFt / 3.28084
        }
    }
    public var speedMph:Double{
        get{
            return speed * 2.23694
        }
        set(speedInMph){
            speed = speedInMph / 2.23694
        }
    }
}

extension Route : Comparable{
    public static func < (lhs: Route, rhs: Route) -> Bool {
        lhs.Name < rhs.Name
    }
    
    public var Name:String{
        name ?? "Unknown name"
    }
    
    public var routePointsArray: [RoutePoint] {
        let routePointsSet = points as? Set<RoutePoint> ?? []
        return routePointsSet.sorted()
    }
}

extension RoutePoint : Comparable{
    public static func < (lhs: RoutePoint, rhs: RoutePoint) -> Bool {
        lhs.index < rhs.index
    }
    
    public var active:Bool{
        return pointRoute!.active
    }
    
    public var suffix:String{
        if pointPin!.type == "fix" && pointRoute!.active{
            return "-\(index)"
        }else{
            return ""
        }
    }
    
    public var Name:String{
            return name ?? "?"
    }
    
    public func setTarget(enabled:Bool){
        target = enabled
    }
}

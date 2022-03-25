//
//  CoreDataExtensions.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import Foundation

extension MapPin : Comparable{
    public static func < (lhs: MapPin, rhs: MapPin) -> Bool {
        lhs.Name < rhs.Name
    }
    
    public var Name:String{
        name ?? "Unknown name"
    }
    
    public var routePointsArray: [RoutePoint]{
        let pinPointSet = pinPoints as? Set<RoutePoint> ?? []
        return pinPointSet.sorted()
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
    
    public var Name:String{
        name ?? "Unknown name"
    }
    
    public func setTarget(enabled:Bool){
        target = enabled
    }
}

//
//  CoreDataExtensions.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import Foundation

extension MapPin : Comparable{
    public static func < (lhs: MapPin, rhs: MapPin) -> Bool {
        lhs.unwrappedName < rhs.unwrappedName
    }
    
    public var unwrappedName:String{
        name ?? "Unknown name"
    }
    
    public var routeArray: [Route]{
        let routeSet = routes as? Set<Route> ?? []
        return routeSet.sorted()
    }
}

extension Route : Comparable{
    public static func < (lhs: Route, rhs: Route) -> Bool {
        lhs.unwrappedName < rhs.unwrappedName
    }
    
    public var unwrappedName:String{
        name ?? "Unknown name"
    }
    
    public var mapPinsArray: [MapPin] {
        let mapPinSet = pins as? Set<MapPin> ?? []
        return mapPinSet.sorted()
    }
}

//
//  RoutePoint+CoreDataProperties.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//
//

import Foundation
import CoreData


extension RoutePoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoutePoint> {
        return NSFetchRequest<RoutePoint>(entityName: "RoutePoint")
    }

    @NSManaged public var name: String?
    @NSManaged public var index: Int16
    @NSManaged public var pointPin: MapPin?
    @NSManaged public var pointRoute: Route?

}

extension RoutePoint : Identifiable {

}

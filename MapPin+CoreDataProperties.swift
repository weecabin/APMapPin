//
//  MapPin+CoreDataProperties.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//
//

import Foundation
import CoreData


extension MapPin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapPin> {
        return NSFetchRequest<MapPin>(entityName: "MapPin")
    }

    @NSManaged public var name: String?
    @NSManaged public var routes: NSSet?

}

// MARK: Generated accessors for routes
extension MapPin {

    @objc(addRoutesObject:)
    @NSManaged public func addToRoutes(_ value: Route)

    @objc(removeRoutesObject:)
    @NSManaged public func removeFromRoutes(_ value: Route)

    @objc(addRoutes:)
    @NSManaged public func addToRoutes(_ values: NSSet)

    @objc(removeRoutes:)
    @NSManaged public func removeFromRoutes(_ values: NSSet)

}

extension MapPin : Identifiable {

}

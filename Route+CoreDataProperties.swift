//
//  Route+CoreDataProperties.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//
//

import Foundation
import CoreData


extension Route {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route> {
        return NSFetchRequest<Route>(entityName: "Route")
    }

    @NSManaged public var name: String?
    @NSManaged public var pins: NSSet?

}

// MARK: Generated accessors for pins
extension Route {

    @objc(addPinsObject:)
    @NSManaged public func addToPins(_ value: MapPin)

    @objc(removePinsObject:)
    @NSManaged public func removeFromPins(_ value: MapPin)

    @objc(addPins:)
    @NSManaged public func addToPins(_ values: NSSet)

    @objc(removePins:)
    @NSManaged public func removeFromPins(_ values: NSSet)

}

extension Route : Identifiable {

}

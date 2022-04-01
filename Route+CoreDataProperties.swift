//
//  Route+CoreDataProperties.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/1/22.
//
//

import Foundation
import CoreData


extension Route {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route> {
        return NSFetchRequest<Route>(entityName: "Route")
    }

    @NSManaged public var name: String?
    @NSManaged public var points: NSSet?

}

// MARK: Generated accessors for points
extension Route {

    @objc(addPointsObject:)
    @NSManaged public func addToPoints(_ value: RoutePoint)

    @objc(removePointsObject:)
    @NSManaged public func removeFromPoints(_ value: RoutePoint)

    @objc(addPoints:)
    @NSManaged public func addToPoints(_ values: NSSet)

    @objc(removePoints:)
    @NSManaged public func removeFromPoints(_ values: NSSet)

}

extension Route : Identifiable {

}

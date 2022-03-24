//
//  MapPin+CoreDataProperties.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/24/22.
//
//

import Foundation
import CoreData


extension MapPin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapPin> {
        return NSFetchRequest<MapPin>(entityName: "MapPin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var pinPoints: NSSet?

}

// MARK: Generated accessors for pinPoints
extension MapPin {

    @objc(addPinPointsObject:)
    @NSManaged public func addToPinPoints(_ value: RoutePoint)

    @objc(removePinPointsObject:)
    @NSManaged public func removeFromPinPoints(_ value: RoutePoint)

    @objc(addPinPoints:)
    @NSManaged public func addToPinPoints(_ values: NSSet)

    @objc(removePinPoints:)
    @NSManaged public func removeFromPinPoints(_ values: NSSet)

}

extension MapPin : Identifiable {

}

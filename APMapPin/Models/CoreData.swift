//
//  CoreData.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import Foundation
import MapKit
import CoreData

class CoreData: ObservableObject {
    
    let container: NSPersistentContainer
    @Published var savedPins: [MapPin] = []
    @Published var savedRoutes: [Route] = []
    @Published var savedRoutePoints: [RoutePoint] = []
    init() {
        container = NSPersistentContainer(name: "MapPinCoreData")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("ERROR LOADING CORE DATA. \(error)")
            }else{
                print("Core Data Loaded")
            }
        }
        initPins()
        initRoutes()
        initRoutePoints()
    }
}
// RoutePoint
extension CoreData{
    func fetchRoutePoints(){
        let request = NSFetchRequest<RoutePoint>(entityName: "RoutePoint")
        do {
            savedRoutePoints = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
        //print("\(savedRoutes) route pins fetched")
    }
    
    func initRoutePoints(){
        fetchRoutePoints()
//        deleteAllRoutePoints()
        if savedRoutePoints.count == 0{
            for i in (1...5){
                let route = RoutePoint(context: container.viewContext)
                route.name = "RP\(i)"
            }
            saveRoutePointData()
        }
        print("Saved RoutePoints = \(savedRoutePoints.count)")
    }
    
    func deleteAllRoutePoints(){
        while savedRoutePoints.count > 0{
            deleteRoutePoint(indexSet:IndexSet(integer: 0))
            saveRoutePointData()
        }
    }
    
    func addRoutePoint(name: String){
        let newRoutePoint = RoutePoint(context: container.viewContext)
        newRoutePoint.name = name
        saveRoutePointData()
    }
    
    func deleteRoutePoint(routePoint: RoutePoint){
        if let count = routePoint.pointRoute?.routePointsArray.count{
            print("points = \(count)")
            let deletedIndex = routePoint.index
            for point in routePoint.pointRoute!.routePointsArray{
                if point.index > deletedIndex{
                    point.index = point.index - 1
                }
            }
        }
        container.viewContext.delete(routePoint)
        saveRoutePointData()
    }
    
    func moveRoutePoint(route:Route, from:Int, to:Int)
    {
        let routeArray = route.routePointsArray
        print(routeArray)
        print("moving \(from) to \(to)")
        let movedRoute = routeArray.first(where: {$0.index == from})
        if from > to{
            for point in routeArray{
                if point.index >= to && point.index < from{
                    point.index = point.index + 1
                }
            }
            movedRoute!.index=Int16(to)
        }else{
            for point in routeArray{
                if point.index > from && point.index < to{
                    point.index = point.index - 1
                }
            }
            movedRoute!.index=Int16(to-1)
        }
        
        saveRouteData()
        saveRoutePointData()
    }
    func deleteRoutePoint(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = savedRoutePoints[index]
        container.viewContext.delete(entity)
        saveRoutePointData()
    }
    
    func saveRoutePointData() {
        do {
            try container.viewContext.save()
            fetchRoutePoints()
        } catch let error {
            print("Error saving. \(error)")
        }
    }
}

// MapPin
extension CoreData{
    func fetchMapPins() {
        let request = NSFetchRequest<MapPin>(entityName: "MapPin")
        do {
            savedPins = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func initPins(){
        fetchMapPins()
//        deleteAllMapPins()
        if savedPins.count == 0{
            for i in (1...5){
                let pin = MapPin(context: container.viewContext)
                pin.name = "P\(i)"
            }
            savePinData()
        }
        print("Saved Pins = \(savedPins.count)")
    }
    
    func deleteAllMapPins(){
        while savedPins.count > 0{
            deleteMapPin(indexSet: IndexSet(integer: 0))
            savePinData()
        }
    }
    
    func addMapPin(name: String) {
        let pin = MapPin(context: container.viewContext)
        pin.name = name
        savePinData()
    }
    
    func deleteMapPin(mapPin: MapPin){
        if mapPin.pinPoints != nil{
            for point in mapPin.routePointsArray{
                deleteRoutePoint(routePoint: point)
            }
        }
        container.viewContext.delete(mapPin)
        savePinData()
    }
    
    func deleteMapPin(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = savedPins[index]
        container.viewContext.delete(entity)
        savePinData()
    }
    
    func savePinData() {
        do {
            try container.viewContext.save()
            fetchMapPins()
        } catch let error {
            print("Error saving. \(error)")
        }
    }
}

// Route
extension CoreData{
    func fetchRoutes(){
        let request = NSFetchRequest<Route>(entityName: "Route")
        do {
            savedRoutes = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
        //print("\(savedRoutes) route pins fetched")
    }
    
    func initRoutes(){
        fetchRoutes()
//        deleteAllRoutePins()
        if savedRoutes.count == 0{
            for i in (1...5){
                let route = Route(context: container.viewContext)
                route.name = "R\(i)"
            }
            saveRouteData()
        }
        print("Saved Routes = \(savedRoutes.count)")
    }
    
    func deleteAllRoutes(){
        while savedRoutes.count > 0{
            deleteRoute(indexSet:IndexSet(integer: 0))
            saveRouteData()
        }
    }
    
    func addRoute(name: String){
        let newRoute = Route(context: container.viewContext)
        newRoute.name = name
        saveRouteData()
    }
    
    func addPinToRoute(route: Route, pin: MapPin){
        let routePoint = RoutePoint(context: container.viewContext)
        routePoint.name = "Some Name"
        routePoint.index = Int16(route.routePointsArray.count)
        routePoint.pointPin = pin
        route.addToPoints(routePoint)
        saveRouteData()
    }
    
    func deleteRoute(route: Route){
        container.viewContext.delete(route)
        saveRouteData()
    }
    
    func deleteRoute(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = savedRoutes[index]
        container.viewContext.delete(entity)
        saveRouteData()
    }
    
    func saveRouteData() {
        do {
            try container.viewContext.save()
            fetchRoutes()
        } catch let error {
            print("Error saving. \(error)")
        }
    }
}

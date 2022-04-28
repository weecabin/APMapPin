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
    
    static let shared = CoreData()
    
    let container: NSPersistentContainer
    @Published var savedPins: [MapPin] = []
    @Published var savedRoutes: [Route] = []
    @Published var savedRoutePoints: [RoutePoint] = []
    @Published var selectedRoutePoints: [RoutePoint] = []
    let deleteAllCoreData:Bool = false
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
        initRoutePoints()
        initRoutes()
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
    }
    
    func toggleSelected(point:RoutePoint){
        point.selected.toggle()
        if point.selected{
            selectedRoutePoints.append(point)
        }else{
            if let index = selectedRoutePoints.firstIndex(of: point){
                selectedRoutePoints.remove(at: index)
            }
            
        }
    }
    
    func initRoutePoints(){
        fetchRoutePoints()
        if deleteAllCoreData{deleteAllRoutePoints()}
        if savedRoutePoints.count == 0{
            for i in (1...5){
                let route = RoutePoint(context: container.viewContext)
                route.name = "RP\(i)"
                route.selected = false
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
    
    func addRoutePoint(name: String) -> RoutePoint{
        let newRoutePoint = RoutePoint(context: container.viewContext)
        newRoutePoint.name = name
        newRoutePoint.target = false
        newRoutePoint.selected = false
        saveRoutePointData()
        return newRoutePoint
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
            saveRouteData()
        }
        container.viewContext.delete(routePoint)
        saveRoutePointData()
    }
    
    func moveRoutePoint(route:Route, from:Int, to:Int){
        let routeArray = route.routePointsArray
//        print(routeArray)
//        print("moving \(from) to \(to)")
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
        if deleteAllCoreData{deleteAllMapPins()}
        if savedPins.count == 0{
            for i in (1...5){
                let pin = MapPin(context: container.viewContext)
                pin.name = "P\(i)"
            }
            savePinData()
            print("saved pins \(savedPins.count)")
        }
    }
    
    func countInRoutes(mapPin: MapPin) -> Int{
        var count = 0
        if let pinPoints = mapPin.pinPoints{
            for point in pinPoints{
                if let route = (point as AnyObject).pointRoute{
                    if route != nil{
                        if savedRoutes.contains(route!){
                            count += 1
                        }
                    }
                }
            }
        }
        return count
    }
    
    func deleteAllMapPins(){
        while savedPins.count > 0{
            deleteMapPin(indexSet: IndexSet(integer: 0))
            savePinData()
        }
    }
    
    @discardableResult func addMapPin(name: String, location:CLLocation, type:String = "fix") -> MapPin{
        let pin = MapPin(context: container.viewContext)
        pin.name = name
        pin.latitude = location.coordinate.latitude
        pin.longitude = location.coordinate.longitude
        pin.course = location.course
        pin.speed = location.speed
        pin.altitude = location.altitude
        pin.type = type
        savePinData()
        return pin
    }
    
    @discardableResult func addMapPin(name: String, latitude:Double = 30, longitude:Double = -124, type:String = "fix") -> MapPin{
        let pin = MapPin(context: container.viewContext)
        pin.name = name
        pin.latitude = latitude
        pin.longitude = longitude
        pin.type = type
        savePinData()
        return pin
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
        print("\(savedRoutes) route pins fetched")
    }
    
    func initRoutes(){
        fetchRoutes()
        if deleteAllCoreData{deleteAllRoutes()}
        if savedRoutes.count == 0{
            for i in (1...5){
                let route = Route(context: container.viewContext)
                route.name = "R\(i)"
            }
            saveRouteData()
        }
    }
    
    func deleteAllRoutes(){
        while savedRoutes.count > 0{
            deleteRoute(indexSet:IndexSet(integer: 0))
            saveRouteData()
        }
    }
    
    func ChangeRouteName(route:Route, name:String){
        for r in savedRoutes{
            if r == route{
                r.name = name
                saveRouteData()
                return
            }
        }
    }
    
    func ClearSelectedPins(route:Route){
        for pin in route.routePointsArray{
            if pin.selected{toggleSelected(point: pin)}
        }
    }
    
    func visiblePointsArray() -> [RoutePoint]{
        var pointsArray:[RoutePoint] = []
        for route in savedRoutes{
            if route.visible{
                pointsArray.append(contentsOf: route.routePointsArray)
            }
        }
        return pointsArray
    }
    
    func setActiveRoute(activeRoute:Route){
        for route in savedRoutes{
            if route == activeRoute{
                route.active = true
            }else{
                route.active = false
            }
        }
        saveRouteData()
    }
    
    func getVisibleRoutes() -> [Route]{
        var routes:[Route] = []
        var foundActive:Bool = false
        for route in savedRoutes{
            if route.visible{
                if route.active{foundActive = true}
                routes.append(route)
            }
        }
        if routes.count > 0{
            if !foundActive{setActiveRoute(activeRoute: routes[0])}
        }
        return routes
    }
    
    func isActiveRouteVisible() -> Bool{
        if let route = getActiveRoute(){
            if route.visible{return true}
        }
        return false
    }
    
    func getActiveRoute() -> Route?{
        for route in savedRoutes{
            if route.active {return route}
        }
        return nil
    }
    
    func selectedRoutePoint(route:Route) -> RoutePoint?{
        for point in route.routePointsArray{
            if point.selected{
                return point
            }
        }
        return nil
    }
    
    func distanceTo(route:Route, routePoint:RoutePoint)->Double?{
        if let index = route.routePointsArray.firstIndex(of: routePoint){
            if index > 0{
                if let fromPin = route.routePointsArray[index-1].pointPin{
                    return fromPin.Location.distance(from: routePoint.pointPin!.Location)
                }
            }
        }
        return nil
    }
    
    func selectedPin(route:Route) -> MapPin?{
        for pin in route.routePointsArray{
            if pin.selected{
                print("Found Selected Pin")
                return pin.pointPin
            }
        }
        return nil
    }
    
    func selectedPinCount()->Int{
        var count = 0
        for route in savedRoutes{
            count = count + selectedPinCount(route: route)
        }
        return count
    }
    
    func selectedPinCount(route:Route) -> Int{
        var count = 0
        for point in route.routePointsArray{
            if point.selected{
                count = count + 1
            }
        }
        return count
    }
    
    func setTarget(route:Route, targetPoint:RoutePoint){
        for point in route.routePointsArray{
            if point == targetPoint{
                point.target = true
            }else{
                point.target = false
            }
        }
    }
    
    func clearTargetedPin(route:Route){
        for point in route.routePointsArray{
            if point.target{
                point.target = false
                return
            }
        }
    }
    
    func getRouteNamed(name:String, createIfNotFound:Bool = false) -> Route?{
        for route in savedRoutes{
            if route.Name == name{return route}
        }
        if createIfNotFound{
            addRoute(name: name)
            return getRouteNamed(name: name)
        }
        return nil
    }
    
    func namedRouteArray(name:String) -> [RoutePoint]{
        if let route = getRouteNamed(name: name){
            return route.routePointsArray
        }
        return []
    }
    
    func addRoute(name: String){
        let newRoute = Route(context: container.viewContext)
        newRoute.name = name
        saveRouteData()
    }
    
    func addPinToRoute(routeName:String, pin: MapPin, atIndex:Int = -1){
        addPinToRoute(route: getRouteNamed(name: routeName, createIfNotFound: true)!, pin: pin, atIndex: atIndex)
    }
    
    func addPinToRoute(route: Route, pin: MapPin, atIndex:Int = -1){
        let routePoint = RoutePoint(context: container.viewContext)
        routePoint.name = "RP"
        routePoint.index = Int16(route.routePointsArray.count)
        routePoint.pointPin = pin
        route.addToPoints(routePoint)
        if atIndex != -1 && atIndex < route.routePointsArray.count-2{
            moveRoutePoint(route: route, from: route.routePointsArray.count-1, to: atIndex+1)
        }
        saveRouteData()
    }
    
    func deleteRoute(route: Route){
        for point in route.routePointsArray{
            if point.pointPin?.pinPoints?.count==1{
                deleteMapPin(mapPin: point.pointPin!)
            }
            deleteRoutePoint(routePoint: point)
        }
        container.viewContext.delete(route)
        saveRouteData()
    }
    
    func deleteRoute(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = savedRoutes[index]
        deleteRoute(route: entity)
//        container.viewContext.delete(entity)
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

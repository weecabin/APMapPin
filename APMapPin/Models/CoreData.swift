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
    
    func addMapPin(_ mapPin: MapPin) {
        let pin = MapPin(context: container.viewContext)
        pin.name = mapPin.name
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
    
    func addRoute(_ route: Route){
        let newRoute = Route(context: container.viewContext)
        newRoute.name = route.name
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

//
//  MapPinViewModel.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import Foundation

class MapPinViewModel: ObservableObject{
    // not sure if it's best to expose coredata or use the published variables below
    @Published var coreData:CoreData = CoreData()
    // If I go the following route, I can make the previous line private
    @Published var pins:[MapPin]?
    @Published var routes:[Route]?
    init(){
        pins = coreData.savedPins
        routes = coreData.savedRoutes
    }
    
}

//
//  Settings.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/10/22.
//

import Foundation

struct BreadCrumbs{
    let defaults = UserDefaults.standard
    let defaultInterval:Double = 60
    let defaultSeparation:Double = 30
    
    var intervalSeconds:Double{
        get{
            defaults.object(forKey:"CrumbSeconds") as? Double ?? defaultInterval
        }
        set(seconds){
            defaults.set(seconds, forKey:"CrumbSeconds")
        }
    }
    var minSeparationMeters:Double{
        get{
            defaults.object(forKey:"CrumbDistance") as? Double ?? defaultSeparation
        }
        set(dist){
            defaults.set(dist, forKey:"CrumbDistance")
        }
    }
    var minSeparationFeet:Double{
        get{
            return minSeparationMeters * 3.28084
        }
        set(dist){
            minSeparationMeters = dist / 3.28084
        }
    }
}

struct Navigation{
    let defaults = UserDefaults.standard
    let defaultArrivalZone:Double = 30
    let defaultInterval:Double = 10
    let defaultProportionalTerm:Double = 2
    let defaultMaxCorrection:Double = 45
    
    var timerMode:Bool{
        get{
            defaults.object(forKey:"NavTimerMode") as? Bool ?? false
        }
        set(enable){
            defaults.set(enable, forKey:"NavTimerMode")
        }
    }
    
    var proportionalTerm:Double{
        get{
            defaults.object(forKey:"NavProportionalTerm") as? Double ?? defaultProportionalTerm
        }
        set(multiple){
            defaults.set(multiple, forKey:"NavProportionalTerm")
        }
    }
    
    var arrivalZoneMeters:Double{
        get{
            defaults.object(forKey:"NavArrivalZone") as? Double ?? defaultArrivalZone
        }
        set(meters){
            defaults.set(meters, forKey:"NavArrivalZone")
        }
    }
    
    var arrivalZoneFeet:Double{
        get{
            arrivalZoneMeters * 3.28084
        }
        set(dist){
            arrivalZoneMeters = dist / 3.28084
        }
    }
    
    var intervalSeconds:Double{
        get{
            defaults.object(forKey:"NavInterval") as? Double ?? defaultInterval
        }
        set(seconds){
            defaults.set(seconds, forKey:"NavInterval")
        }
    }
    
    var maxCorrectionDeg:Double{
        get{
            defaults.object(forKey:"MaxCorrection") as? Double ?? defaultMaxCorrection
        }
        set(newValue){
            defaults.set(newValue, forKey:"MaxCorrection")
        }
    }
}

struct MapSettings{
    let defaults = UserDefaults.standard
    var trackLocation:Bool{
        get{
            defaults.object(forKey:"MapTrackLocation") as? Bool ?? false
        }
        set(enable){
            defaults.set(enable, forKey:"MapTrackLocation")
        }
    }
}

struct Simulator{
    let defaults = UserDefaults.standard
    let defaultSimSpeed:Double = 10
    let defaultWindPercent:Double = 0
    
    
    var enabled:Bool{
        get{
            defaults.object(forKey:"SimEnabled") as? Bool ?? false
        }
        set(enable){
            defaults.set(enable, forKey:"SimEnabled")
        }
    }
    
    var speed:Double{
        get{
            defaults.object(forKey:"SimSpeed") as? Double ?? defaultSimSpeed
        }
        set(newValue){
            defaults.set(newValue, forKey:"SimSpeed")
        }
    }
    
    var windPercent:Double{
        get{
            defaults.object(forKey:"WindPercent") as? Double ?? defaultWindPercent
        }
        set(newValue){
            defaults.set(newValue, forKey:"WindPercent")
        }
    }
    
    
}

struct Settings{
    var breadCrumbs:BreadCrumbs = BreadCrumbs()
    var navigation:Navigation = Navigation()
    var simulator:Simulator = Simulator()
    var map:MapSettings = MapSettings()
}

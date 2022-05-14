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
        set(newValue){
            defaults.set(newValue, forKey:"CrumbSeconds")
        }
    }
    var minSeparationMeters:Double{
        get{
            defaults.object(forKey:"CrumbDistance") as? Double ?? defaultSeparation
        }
        set(newValue){
            defaults.set(newValue, forKey:"CrumbDistance")
        }
    }
    var minSeparationFeet:Double{
        get{
            return minSeparationMeters * 3.28084
        }
        set(newValue){
            minSeparationMeters = newValue / 3.28084
        }
    }
}

struct Navigation{
    let defaults = UserDefaults.standard
    let defaultArrivalZone:Double = 30
    let defaultInterval:Double = 10
    let defaultProportionalTerm:Double = 2
    let defaultIntegralTerm:Double = 0
    let defaultDiffernetialTerm:Double = 0
    let defaultPidLength:Int = 4
    let defaultMaxCorrection:Double = 45
    
    var loopRoute:Bool{
        get{
            defaults.object(forKey:"NavLoopRoute") as? Bool ?? false
        }
        set(enable){
            defaults.set(enable, forKey:"NavLoopRoute")
        }
    }
    
    var phoneHeadingMode:Bool{
        get{
            defaults.object(forKey:"PhoneHeadingMode") as? Bool ?? false
        }
        set(enable){
            defaults.set(enable, forKey:"PhoneHeadingMode")
        }
    }
    
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
        set(newValue){
            defaults.set(newValue, forKey:"NavProportionalTerm")
        }
    }
    
    var integralTerm:Double{
        get{
            defaults.object(forKey:"NavIntegralTerm") as? Double ?? defaultIntegralTerm
        }
        set(newValue){
            defaults.set(newValue, forKey:"NavIntegralTerm")
        }
    }
    
    var differentialTerm:Double{
        get{
            defaults.object(forKey:"NavDifferentialTerm") as? Double ?? defaultDiffernetialTerm
        }
        set(newValue){
            defaults.set(newValue, forKey:"NavDifferentialTerm")
        }
    }
    
    var pidLength:Int{
        get{
            defaults.object(forKey:"NavPidLength") as? Int ?? defaultPidLength
        }
        set(newValue){
            defaults.set(newValue, forKey:"NavPidLength")
        }
    }
    
    var arrivalZoneMeters:Double{
        get{
            defaults.object(forKey:"NavArrivalZone") as? Double ?? defaultArrivalZone
        }
        set(newValue){
            defaults.set(newValue, forKey:"NavArrivalZone")
        }
    }
    
    var arrivalZoneFeet:Double{
        get{
            arrivalZoneMeters * 3.28084
        }
        set(newValue){
            arrivalZoneMeters = newValue / 3.28084
        }
    }
    
    var intervalSeconds:Double{
        get{
            defaults.object(forKey:"NavInterval") as? Double ?? defaultInterval
        }
        set(newValue){
            defaults.set(newValue, forKey:"NavInterval")
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
    let defaultTurnRate:Double = 5
    
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
    
    var turnRate:Double{
        get{
            defaults.object(forKey:"TurnRate") as? Double ?? defaultTurnRate
        }
        set(newValue){
            defaults.set(newValue, forKey:"TurnRate")
        }
    }
    
}

struct Settings{
    var breadCrumbs:BreadCrumbs = BreadCrumbs()
    var navigation:Navigation = Navigation()
    var simulator:Simulator = Simulator()
    var map:MapSettings = MapSettings()
}

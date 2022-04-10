//
//  Settings.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/10/22.
//

import Foundation

struct BreadCrumbs{
    let defaults = UserDefaults.standard

    var intervalSeconds:Double{
        get{
            defaults.object(forKey:"CrumbSeconds") as? Double ?? 60
        }
        set(seconds){
            defaults.set(seconds, forKey:"CrumbSeconds")
        }
    }
    var minSeparationMeters:Double{
        get{
            defaults.object(forKey:"CrumbDistance") as? Double ?? 30
        }
        set(feet){
            defaults.set(feet, forKey:"CrumbDistance")
        }
    }
}

struct Navigation{
    let defaults = UserDefaults.standard
    
    var arrivalZone:Double{
        get{
            defaults.object(forKey:"NavArrivalZone") as? Double ?? 30
        }
        set(meters){
            defaults.set(meters, forKey:"NavArrivalZone")
        }
    }
    var intervalSeconds:Double{
        get{
            defaults.object(forKey:"NavInterval") as? Double ?? 10
        }
        set(seconds){
            defaults.set(seconds, forKey:"NavInterval")
        }
    }
}

struct Settings{
    var breadCrumbs:BreadCrumbs = BreadCrumbs()
    var navigation:Navigation = Navigation()
}

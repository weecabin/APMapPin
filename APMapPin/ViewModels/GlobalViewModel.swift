//
//  GlobalViewModel.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/12/22.
//

import Foundation

/*
 MapViewModel implements the Delegate, enabling other views to stop navigation if needed
 by calling stopNavigation
 */
protocol StopNavigationDelegate{
    func stopNav()
}

class GlobalViewModel : ObservableObject{
    @Published var navType:NavType = NavType.none
    @Published var apIsCalibrated:Bool = false
    @Published var stopNavigationDelegate:StopNavigationDelegate?
    
    func stopNavigation(){
        if let stop = stopNavigationDelegate{
            stop.stopNav()
        }
    }
}

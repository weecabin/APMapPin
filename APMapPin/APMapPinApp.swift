//
//  APMapPinApp.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import SwiftUI

@main
struct APMapPinApp: App {
    @StateObject var mvm:MapViewModel = MapViewModel()
    @StateObject var ble:BLEManager = BLEManager()
    @StateObject var gvm:GlobalViewModel = GlobalViewModel()
    @StateObject var apvm:ApConfigViewModel = ApConfigViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                BLEView()
            }
            .environmentObject(mvm)
            .environmentObject(ble)
            .environmentObject(gvm)
            .environmentObject(apvm)
        }
    }
}

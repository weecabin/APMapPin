//
//  APMapPinApp.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import SwiftUI

@main
struct APMapPinApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView{
                MapPinView()
            }
        }
    }
}

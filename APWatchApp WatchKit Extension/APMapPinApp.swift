//
//  APMapPinApp.swift
//  APWatchApp WatchKit Extension
//
//  Created by Gary Hamann on 4/12/22.
//

import SwiftUI

@main
struct APMapPinApp: App {
    @StateObject var vm:ViewModel = ViewModel()
    @SceneBuilder var body: some Scene {
        WindowGroup {
            TabView {
                TurnView()
                CircleView()
                DropPinView()
            }
            .environmentObject(vm)
        }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

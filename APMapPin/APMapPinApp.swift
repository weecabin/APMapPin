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
    
    @UIApplicationDelegateAdaptor var delegate: FSAppDelegate
    
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

    class FSSceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
        @Published var initialized: Bool = false
        @Published var url: URL?
        @Published var urlString:String? = ""

        func sceneWillEnterForeground(_ scene: UIScene) {
            // ...
        }

        func sceneDidBecomeActive(_ scene: UIScene) {
            // ...
        }

        func sceneWillResignActive(_ scene: UIScene) {
            // ...
        }
        // when app is terminated:
        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            print("yyyyyyyyyyyyyyyyyyyyyyyyyyyyyy")
            
            if let url = connectionOptions.urlContexts.first?.url {
                print(url)
                self.url = url
            }
        }

        // when app is background or foreground:
        func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
            print("xxxxxxxxxxxxxxxxxxxxxx")

            if let url = URLContexts.first?.url {
                print(url)
                urlString = url.absoluteString
                print(urlString!)
                initialized = true
                self.url = url
            }
        }
    }

    class FSAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
        ) -> Bool {
            // ...
            return true
        }

        func application(
            _ application: UIApplication,
            configurationForConnecting connectingSceneSession: UISceneSession,
            options: UIScene.ConnectionOptions
        ) -> UISceneConfiguration {
            let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
            sceneConfig.delegateClass = FSSceneDelegate.self
            return sceneConfig
        }
        // ...
    }


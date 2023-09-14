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
        var url: URL?
        
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
            // ...
        }

        // when app is background or foreground:
        func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
            print("xxxxxxxxxxxxxxxxxxxxxx")

            if let url = URLContexts.first?.url {
                print(url)
                self.url = url
                AddCpxRoute(url: url)
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

func AddCpxRoute(url:URL)
{
    var cd = CoreData.shared
    do {
        let gpxStr = try String(contentsOf: url, encoding: .utf8)
        print(gpxStr)
        let gpxRoute = getLatLon(gpxStr:gpxStr)
        if (cd.getRouteNamed(name: gpxRoute.Name) == nil)
        {
            cd.addRoute(name: gpxRoute.Name)
            for ll in gpxRoute.latLon{
                let pin = cd.addMapPin(name: "fix", latitude: ll.lat, longitude: ll.lon, type: "fix")
                let route = cd.getRouteNamed(name: gpxRoute.Name)!
                route.visible = true
                cd.addPinToRoute(route: route, pin:pin )
            }
        }
    }
    catch {print("Gpx load error")}
}

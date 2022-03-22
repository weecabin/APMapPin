//
//  ContentView.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import SwiftUI

struct MapPinView: View {
    @EnvironmentObject var mvm:MapPinViewModel
    var body: some View {
        VStack{
            ForEach(mvm.coreData.savedPins.sorted()) {pin in
                Text(pin.unwrappedName)
            }
            ForEach(mvm.coreData.savedRoutes.sorted()){ route in
                Text(route.unwrappedName)
            }
        }
    }
}

struct MapPinView_Previews: PreviewProvider {
    static var previews: some View {
        MapPinView()
    }
}

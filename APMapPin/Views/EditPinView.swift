//
//  EditPinView.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/1/22.
//

import SwiftUI

struct EditPinView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var cd = CoreData.shared
    var mapPin:MapPin
    @State var name:String=""

    init(pin:MapPin) {
        mapPin = pin
        name = pin.Name
        print("pin = \(name)")
    }
    
    var body: some View {
        VStack{
            HStack{
                Button("Exit"){presentationMode.wrappedValue.dismiss()}
                    .padding()
                Spacer()
            }
            HStack{
                Text("Name:")
                TextField("name", text: $name)
            }
            Button("Update"){
                mapPin.name = name
                cd.savePinData()
            }
            Spacer()
        }
    }
}

struct EditPinView_Previews: PreviewProvider {
    static var previews: some View {
        EditPinView(pin: CoreData.shared.savedPins[0])
    }
}

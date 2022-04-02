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
    @State var type:String=""

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
                    .textInputAutocapitalization(.never)
            }
            HStack{
                Text("Type:")
                TextField("type", text: $type)
                    .textInputAutocapitalization(.never)
            }
            Button("Update"){
                mapPin.name = name
                mapPin.type = type
                cd.savePinData()
            }
            Spacer()
        }
        .onAppear {
            name = mapPin.Name
            type = mapPin.unwrappedType
        }
    }
}

struct EditPinView_Previews: PreviewProvider {
    static var previews: some View {
        EditPinView(mapPin: CoreData.shared.savedPins[0])
    }
}

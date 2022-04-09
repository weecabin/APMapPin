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
    @State var latitude:String = ""
    @State var longitude:String = ""
    @State var altitude:String = ""
    @State var speed:String = ""
    let h:CGFloat = 30
    var body: some View {
        VStack{
            HStack{
                Button("Exit"){presentationMode.wrappedValue.dismiss()}
                    .padding()
                Spacer()
            }
            HStack{
                VStack(alignment: .trailing){
                    HStack{
                        Text("Name:")
                    }
                    .frame(height: h)
                    HStack{
                        Text("Type:")
                    }
                    .frame(height: h)
                    HStack{
                        Text("Latitude:")
                    }
                    .frame(height: h)
                    HStack{
                        Text("Longitude:")
                    }
                    .frame(height: h)
                    HStack{
                        Text("Altitude(ft):")
                    }
                    .frame(height: h)
                    HStack{
                        Text("Speed(mph):")
                    }
                    .frame(height: h)
                }
                VStack{
                    HStack{
                        TextField("name", text: $name)
                            .textInputAutocapitalization(.never)
                    }
                    .frame(height: h)
                    HStack{
                        TextField("type", text: $type)
                            .textInputAutocapitalization(.never)
                    }
                    .frame(height: h)
                    HStack{
                        TextField("lat", text: $latitude)
                            .textInputAutocapitalization(.never)
                    }
                    .frame(height: h)
                    HStack{
                        TextField("lon", text: $longitude)
                            .textInputAutocapitalization(.never)
                    }
                    .frame(height: h)
                    HStack{
                        TextField("altitude", text: $altitude)
                            .textInputAutocapitalization(.never)
                    }
                    .frame(height: h)
                    HStack{
                        TextField("speed", text: $speed)
                            .textInputAutocapitalization(.never)
                    }
                    .frame(height: h)
                }
            }
            Button {
                mapPin.name = name
                mapPin.type = type
                mapPin.speedMph = Double(speed) ?? 0
                mapPin.altInFeet = Double(altitude) ?? 0
                mapPin.latitude = Double(latitude) ?? 0
                mapPin.longitude = Double(longitude) ?? 0
                cd.savePinData()
            } label: {
                Text("Update")
                    .frame(width: 100, height: 30)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            name = mapPin.Name
            type = mapPin.unwrappedType
            latitude = String(mapPin.latitude)
            longitude = String(mapPin.longitude)
            altitude = String(mapPin.altInFeet)
            speed = String(mapPin.speedMph)
        }
    }
}

struct EditPinView_Previews: PreviewProvider {
    static var previews: some View {
        EditPinView(mapPin: CoreData.shared.savedPins[0])
    }
}

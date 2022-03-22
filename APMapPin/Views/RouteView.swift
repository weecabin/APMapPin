//
//  RouteView.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/22/22.
//

import SwiftUI

struct RouteView: View {
    @StateObject var vm = CoreData()
    @State var name:String = ""
    var body: some View {
        VStack(alignment: .leading){
            VStack{
                HStack{
                    Text("Name:")
                    TextField("name",text: $name)
                        .padding()
                }
                Button {
                    if name.count > 0 {vm.addRoute(name: name)}
                } label: {
                    Text("Add")
                }
            }
            Text("Routes")
                .padding()
                .font(.headline)
            ForEach(vm.savedRoutes.sorted()) {route in
                HStack{
                    Text("Name:")
                    Text(route.Name)
                    Button {
                        vm.deleteRoute(route: route)
                    } label: {
                        Text("Del")
                    }
                }
            }
            .padding(.leading, 10)
            .padding(.top,5)
            Spacer()
        }
    }
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            RouteView()
        }
        .environmentObject(MapPinViewModel())
    }
}

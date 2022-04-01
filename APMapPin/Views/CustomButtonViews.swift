//
//  CustomButtonViews.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/31/22.
//

import SwiftUI

struct PlusFixView : View {
    var width:CGFloat = 40
    var height:CGFloat = 40
    var body : some View{
        VStack{
            ZStack{
                Image(systemName: "diamond")
                Image(systemName: "plus")
            }
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

struct AddPinToRouteView : View {
    var width:CGFloat = 40
    var height:CGFloat = 40
    var body : some View {
        VStack{
            ZStack{
                Image(systemName: "point.filled.topleft.down.curvedto.point.bottomright.up")
                    .offset(x: 4, y: -3)
                Image(systemName: "plus")
                    .font(.headline)
                    .scaleEffect(0.9)
                    .offset(x: -4, y: 5)
            }
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

struct RunRouteView : View {
    var width:CGFloat = 40
    var height:CGFloat = 40
    var body : some View {
        VStack{
            ZStack{
                Image(systemName: "point.filled.topleft.down.curvedto.point.bottomright.up")
                    .offset(x: 4, y: -3)
                Image(systemName: "play.fill")
                    .font(.headline)
                    .scaleEffect(0.75)
                    .offset(x: -4, y: 5)
            }
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

struct StopRouteView : View {
    var width:CGFloat = 40
    var height:CGFloat = 40
    var body : some View {
        VStack{
            ZStack{
                Image(systemName: "point.filled.topleft.down.curvedto.point.bottomright.up")
                    .offset(x: 4, y: -3)
                Image(systemName: "stop.fill")
                    .font(.headline)
                    .scaleEffect(0.75)
                    .offset(x: -4, y: 5)
            }
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

struct DeleteRouteView : View {
    var width:CGFloat = 40
    var height:CGFloat = 40
    var body : some View {
        VStack{
            ZStack{
                Image(systemName: "point.filled.topleft.down.curvedto.point.bottomright.up")
                    .offset(x: 4, y:-3)
                Image(systemName: "trash")
                    .font(.headline)
                    .scaleEffect(0.75)
                    .offset(x: -6, y: 6)
            }
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

struct GoToX : View {
    var width:CGFloat = 40
    var height:CGFloat = 40
    var body : some View{
        VStack{
            ZStack{
                Image(systemName: "play.fill")
                    .offset(x:-6, y:0)
                Text("X")
                    .offset(x:7, y:0)
            }
        }
        .frame(width: width, height: height, alignment: .center)
    }
}
struct CustomButtonViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            PlusFixView()
            AddPinToRouteView()
                .background(.blue)
            RunRouteView()
                .background(.blue)
            StopRouteView()
                .background(.blue)
            DeleteRouteView()
                .background(.blue)
            GoToX()
                .background(.blue)
        }
    }
}

//
//  MapAnnotationView.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/25/22.
//

import SwiftUI
import MapKit

struct AnnotationView: View{
    var type:String
    var foreColor:Color
    var label:String
    var rotate:Double
    var backColor:Color
    init(type:String = "fix", label:String = "fix", rotate:Double=0, foreColor:Color = Color.red, backColor:Color = .clear){
        self.type = type
        self.foreColor = foreColor
        self.label = label
        self.rotate = rotate
        self.backColor = backColor
    }
    
    var body: some View {
        VStack(spacing:0){
            switch (type){
            case "sim":
                VStack(spacing:0){
                    Image(systemName: rotate >= 0 ? "paperplane.fill" : "questionmark.diamond")
                        .resizable()
                        .scaledToFit()
                        .font(.headline)
                        .frame(width: 20, height: 20)
                        .foregroundColor(foreColor)
                        .background(backColor.opacity(0.5))
                        .rotationEffect(Angle(degrees: rotate >= 0 ? -45 + rotate : 0))
                        .offset(y:10)
                    Text(label)
                        .font(.footnote)
                        .offset(y:5)
                }
            case "fish":
                VStack(spacing:0){
                    Image("FatFish")
                        .resizable()
                        .scaledToFit()
                        .font(.headline)
                        .frame(width: 20, height: 20)
                        .foregroundColor(foreColor)
                        .background(backColor.opacity(0.5))
                        .rotationEffect(Angle(degrees: rotate >= 0 ? -90 + rotate : 0))
                    Text(label)
                        .font(.footnote)
                        .offset(y:-3)
                }
                .offset(y:8)
            case "track":
                VStack(spacing:0){
                    Image(systemName: rotate >= 0 ? "paperplane.fill" : "questionmark.diamond")
                        .resizable()
                        .scaledToFit()
                        .font(.headline)
                        .frame(width: 20, height: 20)
                        .foregroundColor(foreColor)
                        .background(backColor.opacity(0.5))
                        .rotationEffect(Angle(degrees: rotate >= 0 ? -45 + rotate : 0))
                        .offset(y:10)
                    Text(label)
                        .font(.footnote)
                        .offset(y:5)
                }
            case "home":
                VStack(spacing:0){
                    Image(systemName: "house.circle")
                        .resizable()
                        .scaledToFit()
                        .font(.headline)
                        .frame(width: 20, height: 20)
                        .foregroundColor(foreColor)
                        .background(backColor.opacity(0.5))
                        .offset(y:10)
                    Text(label)
                        .font(.footnote)
                        .offset(y:5)
                }
            case "fix":
                VStack(spacing:0){
                    Image(systemName: "suit.diamond")
                        .resizable()
                        .scaledToFit()
                        .font(.headline)
                        .frame(width: 20, height: 20)
                        .foregroundColor(foreColor)
                        .background(backColor.opacity(0.5))
                    //                .opacity(0.3)
                        .cornerRadius(10)
                    Text(label)
                        .font(.footnote)
                        .offset(y:-2)
                }
                .offset(y:8)
            case "shallow":
                VStack{
                    ZStack{
                        Image(systemName: "ferry")
                            .resizable()
                            .scaledToFit()
                            .font(.headline)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                        Image(systemName: "multiply")
                            .resizable()
                            .scaledToFit()
                            .font(.callout)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                    }
//                    .offset(y:10)
//                    Text(label)
//                        .font(.footnote)
//                        .offset(y:-10)
                }
            default:
                VStack(spacing:0){
                    Image(systemName: "suit.diamond")
                        .resizable()
                        .scaledToFit()
                        .font(.headline)
                        .frame(width: 20, height: 20)
                        .foregroundColor(foreColor)
                        .background(backColor.opacity(0.5))
                    //                .opacity(0.3)
                        .cornerRadius(10)
                    Text(label)
                        .font(.footnote)
                        .offset(y:-5)
                }
            }
        }
    }
}


struct MapAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        HStack{
            VStack{
                ZStack{
                    AnnotationView(type:"fish",label:"fish",rotate: 0)
                    Text("X")
                }
                ZStack{
                    AnnotationView(type:"fish",label:"fish",rotate: 90)
                    Text("X")
                }
                ZStack{
                    AnnotationView(type:"fish",label:"fish",rotate: 180)
                    Text("X")
                }
                ZStack{
                    AnnotationView(type:"fish",label:"fish",rotate: -1)
                    Text("X")
                }
            }
            VStack{
                ZStack{
                    AnnotationView(type:"shallow")
                    Text("X")
                }
                ZStack{
                    AnnotationView(type:"home", label: "home")
                    Text("X")
                }
                ZStack{
                    AnnotationView(type:"fix",backColor:.blue)
                    Text("X")
                }
                
                
                
            }
        }
//        HStack{
//            VStack{
//                FishAnnotationView(rotate: 0)
//                FishAnnotationView(rotate: 90)
//                FishAnnotationView(rotate: 180)
//                FishAnnotationView(rotate: -1)
//            }
//            VStack{
//                ShallowAnnotationView()
//                HomeAnnotationView()
//                WaypointAnnotationView(backColor:.blue)
//            }
//        }
    }
}

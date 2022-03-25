//
//  MapAnnotationView.swift
//  APMapPin
//
//  Created by Gary Hamann on 3/25/22.
//

import SwiftUI
import MapKit

struct HomeAnnotationView: View {
    
    let accentColor = Color.red
    var label:String = "Home"
    
    init(label:String = "Home"){
        self.label = label
    }
    var body: some View {
        VStack(spacing:0){
            Image(systemName: "house.circle")
                .resizable()
                .scaledToFit()
                .font(.headline)
                .frame(width: 20, height: 20)
                .foregroundColor(accentColor)
            Text(label)
                .font(.footnote)
                .offset(y:-5)
        }
    }
}

struct FishAnnotationView: View {
    
    let accentColor  = Color.red
    var label:String
    var rotate:Double
    init(label:String = "Fish", rotate:Double=0){
        self.label = label
        self.rotate = rotate
    }
    
    var body: some View {
        VStack(spacing:0){
            Image(systemName: rotate >= 0 ? "paperplane.fill" : "questionmark.diamond")
                .resizable()
                .scaledToFit()
                .font(.headline)
                .frame(width: 20, height: 20)
                .foregroundColor(accentColor)
                .rotationEffect(Angle(degrees: rotate >= 0 ? -45 + rotate : 0))
            Text(label)
                .font(.footnote)
                .offset(y:-5)
        }
    }
}

struct ShallowAnnotationView: View {
    
    let accentColor = Color.red
    var label:String
    
    init(label:String = "Shallow"){
        self.label = label
    }

    var body: some View {
        VStack{
            ZStack{
                Image(systemName: "ferry")
                    .resizable()
                    .scaledToFit()
                    .font(.headline)
                    .frame(width: 20, height: 20)
                    .foregroundColor(accentColor)
                Image(systemName: "multiply")
                    .resizable()
                    .scaledToFit()
                    .font(.callout)
                    .frame(width: 20, height: 20)
                    .foregroundColor(accentColor)
            }
            Text(label)
                .font(.footnote)
                .offset(y:-10)
        }
        
    }
}

struct WaypointAnnotationView: View {
    
    let accentColor = Color.red
    var label:String = "Fix"
    var backColor:Color = Color.clear
    
    init(label:String = "Fix", backColor:Color = Color.clear){
        self.label = label
        self.backColor = backColor
    }
    var body: some View {
        VStack(spacing:0){
            Image(systemName: "suit.diamond")
                .resizable()
                .scaledToFit()
                .font(.headline)
                .frame(width: 20, height: 20)
                .foregroundColor(accentColor)
                .background(backColor.opacity(0.5))
//                .opacity(0.3)
                .cornerRadius(10)
            Text(label)
                .font(.footnote)
                .offset(y:-5)
        }
    }
}


struct MapAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        HStack{
            VStack{
                FishAnnotationView(rotate: 0)
                FishAnnotationView(rotate: 90)
                FishAnnotationView(rotate: 180)
                FishAnnotationView(rotate: -1)
            }
            VStack{
                ShallowAnnotationView()
                HomeAnnotationView()
                WaypointAnnotationView(backColor:.blue)
            }
        }
        
        
    }
}

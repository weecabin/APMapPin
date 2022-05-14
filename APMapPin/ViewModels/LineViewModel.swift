//
//  ViewModel.swift
//  LineChart
//
//  Created by Gary Hamann on 4/24/22.
//

import SwiftUI

struct dataPoint:Comparable{
    static func < (lhs: dataPoint, rhs: dataPoint) -> Bool {
        lhs.x < rhs.x
    }
    let x:Double
    let y:Double
}

class DataLine:Identifiable{
    var points:[dataPoint]?
    var sortedPoints:[dataPoint] = []
    let color:Color
    let name:String
    var maxX:Double = -Double.greatestFiniteMagnitude
    var minX:Double = Double.greatestFiniteMagnitude
    var maxY:Double = -Double.greatestFiniteMagnitude
    var minY:Double = Double.greatestFiniteMagnitude
    
    init(color:Color, name:String = ""){
        self.name = name
        self.color = color
    }
    
    func addPoint(point:dataPoint){
        if points==nil{points = []}
        points!.append(point)
        if point.x > maxX {maxX = point.x}
        if point.x < minX {minX = point.x}
        if point.y > maxY {maxY = point.y}
        if point.y < minY {minY = point.y}
    }
    
    func contains(x:Double)->Bool{
        x >= minX && x <= maxX
    }
    
    func interpolate(x:Double) -> Double?{
        guard contains(x: x) else {return nil}
        if let index = sortedPoints.lastIndex(where: {x >= $0.x}){
            if index<0 || (index+1) > (sortedPoints.count-1) {return nil}
            let xa = sortedPoints[index].x
            let ya = sortedPoints[index].y
            let xb = sortedPoints[index+1].x
            let yb = sortedPoints[index+1].y
            let interpolatedY = ya + (yb-ya)*(x-xa)/(xb-xa)
//            print("name \(name) x \(x) index: \(index) xa:\(xa) ya:\(ya) xb:\(xb) yb:\(yb) y: \(interpolatedY)")
            return interpolatedY
        }
        return nil
    }
}

struct DataToPlot{
    var lines:[DataLine] = []
    var maxX:Double = -Double.greatestFiniteMagnitude
    var minX:Double = Double.greatestFiniteMagnitude
    var maxY:Double = -Double.greatestFiniteMagnitude
    var minY:Double = Double.greatestFiniteMagnitude

    var maxCount:Int{
        get{
            var maxCount = 0
            for line in lines{
                if let points = line.points{
                    if points.count > maxCount {maxCount = points.count}
                }
                
            }
            return maxCount
        }
    }
    var lineCount:Int{
        return lines.count
    }
    func getLine(lineName:String)->DataLine?{
        if let line = lines.first(where: {lineName == $0.name}){
            return line
        }
        return nil
    }
    mutating func removeLine(lineName:String){
        if let index = lines.firstIndex(where: {$0.name==lineName}){
            lines.remove(at: index)
            maxX = -Double.greatestFiniteMagnitude
            minX = Double.greatestFiniteMagnitude
            maxY = -Double.greatestFiniteMagnitude
            minY = Double.greatestFiniteMagnitude
            for line in lines{
                if line.maxX > maxX {maxX = line.maxX}
                if line.minX < minX {minX = line.minX}
                if line.maxY > maxY {maxY = line.maxY}
                if line.minY < minY {minY = line.minY}
            }
        }
    }
    mutating func addDataToLine(lineName:String, point:dataPoint){
        if let line = getLine(lineName: lineName){
            line.addPoint(point: point)
            if line.maxX > maxX {maxX = line.maxX}
            if line.minX < minX {minX = line.minX}
            if line.maxY > maxY {maxY = line.maxY}
            if line.minY < minY {minY = line.minY}
            line.sortedPoints = line.points!.sorted()
        }
    }
    mutating func addLine(line:DataLine){
        if line.maxX > maxX {maxX = line.maxX}
        if line.minX < minX {minX = line.minX}
        if line.maxY > maxY {maxY = line.maxY}
        if line.minY < minY {minY = line.minY}
            lines.append(line)
        line.sortedPoints = line.points!.sorted()
//        print(line.name)
//        for point in line.points!.sorted(){
//            print("\(point.x),\(point.y)")
//        }
    }
    func getLines()->[DataLine]?{
        if lines.isEmpty {return nil}
        return lines
    }
}
func getPlotStartData(name:String) ->DataToPlot{
    var data = DataToPlot()
    let dataLine1 = DataLine(color: .clear, name: name)
    dataLine1.addPoint(point: dataPoint(x: 0, y: 0))
    dataLine1.addPoint(point: dataPoint(x: 60, y: 360))
    data.addLine(line: dataLine1)
    return data
}

func getData() -> DataToPlot {
    var data = DataToPlot()

    var x=0
    let dataLine1 = DataLine(color: .red, name: "y = 10x")
    x = -10
    while x <= 10{
        dataLine1.addPoint(point: dataPoint(x: Double(x), y: Double(10*x)))
        x+=1
    }
    data.addLine(line: dataLine1)
 
    let dataLine2 = DataLine(color: .blue, name: "y = 100*sin(x)")
    var theta:Double = -10
    while theta <= 10{
        dataLine2.addPoint(point: dataPoint(x: theta, y: 100*sin(theta)))
        theta += 0.1
    }
    data.addLine(line: dataLine2)

    //print(data)
    return data
}

class Screen{
    var minWorldX:Double
    var minWorldY:Double
    var maxWorldX:Double
    var maxWorldY:Double
    var maxScreenX:Int
    var maxScreenY:Int
    
    init(minWorldX:Double, minWorldY:Double,maxWorldX:Double,maxWorldY:Double,maxScreenX:Int,maxScreenY:Int){
        self.minWorldX = minWorldX
        self.minWorldY = minWorldY
        self.maxWorldX = maxWorldX
        self.maxWorldY = maxWorldY
        self.maxScreenX = maxScreenX
        self.maxScreenY = maxScreenY
    }
    
    var worldToScreenScaleX:Double{
        var delta = maxWorldX - minWorldX
        if delta == 0{delta = 0.001}
        return Double(maxScreenX) / delta
    }
    var worldToScreenScaleY:Double{
        var delta = maxWorldY - minWorldY
        if delta == 0{delta = 0.001}
        return Double(maxScreenY) / delta
    }
    
    func worldY(screenY:Int)->Double{
        let wy = Double(screenY)/worldToScreenScaleY + minWorldY
        return wy
    }
    func worldX(screenX:Int)->Double{
        let wx = Double(screenX)/worldToScreenScaleX + minWorldX
        return wx
    }
    func screenCenter()->Int{
        return maxScreenX/2
    }
    func screenX(worldX:Double)->Int?{
        if (worldX < minWorldX) || (worldX > maxWorldX) {return nil}
        let x = worldX - minWorldX
        return Int(x * worldToScreenScaleX)
    }
    func screenY(worldY:Double)->Int?{
        if (worldY < minWorldY) || (worldY > maxWorldY) {return nil}
        let y = worldY - minWorldY
        return Int(y * worldToScreenScaleY)
    }
    func screenXY(worldX:Double, worldY:Double)->(x:Int,y:Int)?{
        if let sx = screenX(worldX:worldX),
           let sy = screenY(worldY:worldY){
            return (x:sx,y:sy)
        }
        return nil
    }
}

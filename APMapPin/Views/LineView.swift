//
//  LineChartView2.swift
//  LineChart
//
//  Created by Gary Hamann on 4/24/22.
//

import SwiftUI


struct LineChartView: View {
    var data:DataToPlot
    let plotWidth:CGFloat
    let plotHeight:CGFloat
    @State var dragLine:CGPoint = CGPoint(x: 0, y: 0)
    let screen:Screen?
    @State var selectedLine:DataLine?
    @State var selectedLineValue:String = ""
    init(data:DataToPlot,plotWidth:CGFloat,plotHeight:CGFloat){
        self.data = data
        self.plotWidth = plotWidth
        self.plotHeight = plotHeight
        screen = Screen(
            minWorldX: data.minX,
            minWorldY: data.minY,
            maxWorldX: data.maxX,
            maxWorldY: data.maxY,
            maxScreenX: Int(plotWidth),
            maxScreenY: Int(plotHeight))
    }
    
    var body: some View {
        VStack{
            HStack{
                Button {dragLine = CGPoint(x: plotWidth/2, y: 0)} label: {Text("Find Cursor")}
                Spacer()
            }
            if let lines = data.getLines(){
                ForEach(lines){line in
                    HStack{
                        Text("\(line.name) = \(selectedLineValueString(line:line))")
                            .padding(5)
                            .background(line.name==selectedLine?.name ? .yellow : .clear)
                            .onTapGesture {
                                selectedLine = line
                                updateSelectedLineValue()
                            }
                        Spacer()
                    }
                }
            }
            
        }.padding()
        Divider()
        ScrollView(.horizontal, showsIndicators: false){
            VStack {
                ZStack{
                    ForEach((0...data.lineCount-1), id: \.self){
                        LineView(
                            line: data.getLines()![$0],
                            screen: Screen(
                                minWorldX: data.minX,
                                minWorldY: data.minY,
                                maxWorldX: data.maxX,
                                maxWorldY: data.maxY,
                                maxScreenX: Int(plotWidth),
                                maxScreenY: Int(plotHeight)))
                    }
                    dataLine(xLocation: Int(dragLine.x), screen: screen!)
                    Text("\(xValueString()),\(selectedLineValue)")
                        .frame(height:30)
                        .position(x: dragLine.x, y: 15)
                        .gesture(drag)
                    Image(systemName: "arrow.left.arrow.right")
                        .frame(height:30)
                        .position(x: dragLine.x, y: CGFloat(plotHeight+50))
                        .gesture(drag)
                    Axis(data: data, screen: screen!)
                }
            }
            .frame(width: plotWidth, height: plotHeight + 70)
            .padding(0)
        }
        .onAppear {
            selectedLine = data.getLines()![0]
            dragLine = CGPoint(x: plotWidth/2, y: 0)
        }
        Spacer()
    }
    var drag: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                dragLine = value.location
                updateSelectedLineValue()
            }
    }
    func setExtents(){
        if let s = screen{
            s.minWorldX = data.minX
            s.minWorldY = data.minY
            s.maxWorldX = data.maxX
            s.maxWorldY = data.maxY
            s.maxScreenX = Int(plotWidth)
            s.maxScreenY = Int(plotHeight)
        }
    }
    func xValueString()->String{
        let x = screen!.worldX(screenX: Int(dragLine.x))
        return String(format: "%.2f", x)
    }
    
    func updateSelectedLineValue(){
        if let line = selectedLine{
            selectedLineValue = selectedLineValueString(line: line)
        }
    }
    
    func selectedLineValue(line:DataLine)->Double?{
            if let y = line.interpolate(x: screen!.worldX(screenX: Int(dragLine.x)) ){
                return y
        }
        return nil
    }
    
    func selectedLineValueString(line:DataLine)->String{
        if let value = selectedLineValue(line: line){
            return String(format: "%.2f", value)
        }
        return "?"
    }
}

func dataLine(xLocation:Int, screen:Screen)->LineView{
    let line = DataLine(color: .black)
    line.addPoint(point: dataPoint.init(x: screen.worldX(screenX: xLocation), y: screen.minWorldY))
    line.addPoint(point: dataPoint.init(x: screen.worldX(screenX: xLocation), y: screen.maxWorldY))
    return LineView(line: line, screen: screen)
}

struct Axis: View{
    let data:DataToPlot
    let screen:Screen
    let color:Color
    
    init(data:DataToPlot, screen:Screen, color:Color = .gray){
        self.screen = screen
        self.data = data
        self.color = color
    }

    private var axis:Path?{
        var path = Path()
        var ok = false;
        if data.minY < 0 && data.maxY > 0{
            ok = true
            let x1 = screen.screenX(worldX: 0)!
            let y1 = screen.screenY(worldY: data.minY)!
            let x2 = screen.screenX(worldX: 0)!
            let y2 = screen.screenY(worldY: data.maxY)!
            path.move(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x2, y: y2))
        }
        if data.minX < 0 && data.maxY > 0{
            ok = true
            let x1 = screen.screenX(worldX: data.minX)!
            let y1 = screen.screenY(worldY: 0)!
            let x2 = screen.screenX(worldX: data.maxX)!
            let y2 = screen.screenY(worldY: 0)!
            path.move(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x2, y: y2))
        }
        if ok{
            return path
        }
        return nil
    }
    
    var body: some View {
        VStack {
            if let axisOk = axis{
                axisOk
                    .stroke(color, lineWidth: 2)
                    .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                    .frame(maxWidth: .infinity, maxHeight: CGFloat(screen.maxScreenY))
            }
        }
    }
}

struct LineView: View {
    let line:DataLine
    let screen:Screen
    
    init(line:DataLine, screen:Screen){
        self.line = line
        self.screen = screen
//        print("minY:\(screen.minWorldY) maxY:\(screen.maxWorldY)")
    }

    private var path: Path {
        if line.points==nil {return Path()}
        var path = Path()
        var foundFirst:Bool = false
        
        for point in line.points!{
            if let xy = screen.screenXY(worldX: point.x, worldY: point.y){
                if !foundFirst{
                    path.move(to: CGPoint(x: xy.x, y: xy.y))
                    foundFirst = true
                }else{
                    path.addLine(to: CGPoint(x: xy.x, y: xy.y))
                }
            }
        }
        return path
    }
    
    var body: some View {
        VStack {
            path.stroke(line.color, lineWidth: 2)
                .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                .frame(maxWidth: .infinity, maxHeight: CGFloat(screen.maxScreenY))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartView(data:getData(),plotWidth: 800,plotHeight: 500)
    }
}

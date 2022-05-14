//
//  NavPlotView.swift
//  APMapPin
//
//  Created by Gary Hamann on 5/13/22.
//

import SwiftUI
protocol PlotDataDelegate{
    func plotData(message:String)
}

struct NavPlotView: View {
    @EnvironmentObject var ble:BLEManager
    @State var data:DataToPlot
    @State var plotHeight:CGFloat = 200
    @State var plotWidth:CGFloat = 800
    @State var timer:Timer?
    @State var x:Double = 0
    var body: some View {
        VStack{
            LineChartView(data: data, plotWidth: plotWidth, plotHeight: plotHeight)
            HStack{
                Button {zoom(true)} label: {Text("ZoomIn")}
                Button {zoom(false)} label: {Text("ZoomOut")}
            }
            .onAppear {
                OnAppear()
            }
            .onDisappear {
                ble.plotHeadingDelegate = nil
                if timer != nil{
                    timer?.invalidate()
                }
                
            }
        }
    }
    func zoom(_ zoomIn:Bool){
        if zoomIn {
            plotWidth *= 1.5
        }else{
            plotWidth /= 1.5
        }
    }
    func OnAppear(){
        ble.plotHeadingDelegate = self
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { Timer in
            self.GetHeadingData()
        }
    }
    func GetHeadingData(){
        ble.sendMessageToAP(data: "\(CMD_GET_PLOT_DATA)")
    }
}

extension NavPlotView:PlotDataDelegate{
    func plotData(message:String) {
        let msg = message.replacingOccurrences(of: "<EOM>\n\n", with: "")
        if message.contains("plt="){
            print(message)
            let p = convert(msg: msg, names: ["hdg","tgt"])
            if data.lines.count == 1{
                let hdgLine = DataLine(color: .green, name: "Hdg")
                hdgLine.addPoint(point: dataPoint(x: x, y: p["hdg"] ?? 0))
                let tgtLine = DataLine(color: .blue, name: "Tgt")
                tgtLine.addPoint(point: dataPoint(x: x, y: p["tgt"] ?? 0))
                data.addLine(line: hdgLine)
                data.addLine(line: tgtLine)
            }else{
                data.addDataToLine(lineName: "Hdg", point: dataPoint(x: x, y: p["hdg"] ?? 0))
                data.addDataToLine(lineName: "Tgt", point: dataPoint(x: x, y: p["tgt"] ?? 0))
                data.removeLine(lineName: "start")
            }
            x += 1
        }
    }
    
}

struct NavPlotView_Previews: PreviewProvider {
    static var previews: some View {
        NavPlotView(data: getData())
            .environmentObject(BLEManager())
    }
}

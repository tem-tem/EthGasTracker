//
//  LowChart.swift
//  EthGasTracker
//
//  Created by Tem on 5/6/23.
//

import SwiftUI
import Charts

struct LowChart: View {
    @AppStorage("dataUpdateToggle") var dataUpdateToggle = false
    
    var gasList: [GasData]
    var lowMin: Double
    var lowMax: Double
//    private var gasListLoader = GasListLoader()
//    private var gasList: [GasData]
    
    private let curColor = Color("low")
    private let curGradient: LinearGradient

    init(gasList inputGasData: [GasData], min: Double, max: Double) {
        gasList = inputGasData
        lowMin = min
        lowMax = max
//        gasList = gasListLoader.loadGasDataListFromUserDefaults()
        curGradient = LinearGradient(
            gradient: Gradient (
                colors: [
                    curColor.opacity(0.5),
                    curColor.opacity(0.0),
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        Chart(gasList.prefix(CHART_RANGE)) {
            if ($0.timestamp == gasList.first!.timestamp) {
                LineMark(
                    x: .value("Timestamp", Date(timeIntervalSince1970: TimeInterval($0.timestamp))),
                    y: .value("Price", Int($0.SafeGasPrice) ?? 0)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(curColor)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .symbol() {
                    Circle()
                        .fill(curColor)
                        .frame(width: 10)
                }
            }
            LineMark(
                x: .value("Timestamp", Date(timeIntervalSince1970: TimeInterval($0.timestamp))),
                y: .value("Price", Int($0.SafeGasPrice) ?? 0)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(curColor)
            .lineStyle(StrokeStyle(lineWidth: 3))
            
            AreaMark(
                x: .value("Timestamp", Date(timeIntervalSince1970: TimeInterval($0.timestamp))),
                yStart: .value("Price Start", Int($0.SafeGasPrice) ?? 0),
                yEnd: .value("Price End", Int(lowMin))
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(curGradient)
//            }
        }
        
        .chartYScale(domain: lowMin...lowMax)
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .animation(.easeIn, value: dataUpdateToggle)
    }
}

//struct LowChart_Previews: PreviewProvider {
//    static var previews: some View {
//        LowChart()
//    }
//}

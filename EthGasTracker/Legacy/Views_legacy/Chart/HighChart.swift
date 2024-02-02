//
//  HighChart.swift
//  EthGasTracker
//
//  Created by Tem on 5/6/23.
//

import SwiftUI
import Charts

struct HighChart: View {
    @AppStorage("dataUpdateToggle") var dataUpdateToggle = false
    
//    private var gasListLoader = GasListLoader()
    var gasList: [GasData]
    var highMin: Double
    var highMax: Double
    
    private let curColor = Color("high")
    private let curGradient: LinearGradient

    init(gasList inputGasList: [GasData], min: Double, max: Double) {
        gasList = inputGasList
        highMin = min
        highMax = max
        
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
                    y: .value("Price", Int($0.FastGasPrice) ?? 0)
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
                y: .value("Price", Int($0.FastGasPrice) ?? 0)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(curColor)
            .lineStyle(StrokeStyle(lineWidth: 3))
            
            AreaMark(
                x: .value("Timestamp", Date(timeIntervalSince1970: TimeInterval($0.timestamp))),
                yStart: .value("Price Start", Int($0.FastGasPrice) ?? 0),
                yEnd: .value("Price End", Int(highMin))
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(curGradient)
//            }
        }
        
        .chartYScale(domain: highMin...highMax)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .animation(.easeIn, value: dataUpdateToggle)
    }
}

//struct HighChart_Previews: PreviewProvider {
//    static var previews: some View {
//        HighChart()
//    }
//}

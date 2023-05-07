//
//  LineChart.swift
//  EthGasTracker
//
//  Created by Tem on 5/6/23.
//

import SwiftUI
import Charts

struct AvgChart: View {
    private var gasListLoader = GasListLoader()
    private var gasList: [GasData]
    
    @AppStorage("avgMin") var avgMin: Double = 0.0
    @AppStorage("avgMax") var avgMax: Double = 9999.0
    
    private let curColor = Color("avg")
    private let curGradient: LinearGradient

    init() {
        gasList = gasListLoader.loadGasDataListFromUserDefaults()
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
                PointMark(
                    x: .value("Timestamp", Date(timeIntervalSince1970: TimeInterval($0.timestamp))),
                    y: .value("Price", Int($0.ProposeGasPrice) ?? 0)
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
                y: .value("Price", Int($0.ProposeGasPrice) ?? 0)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(curColor)
            .lineStyle(StrokeStyle(lineWidth: 3))
            
            AreaMark(
                x: .value("Timestamp", Date(timeIntervalSince1970: TimeInterval($0.timestamp))),
                yStart: .value("Price Start", Int($0.ProposeGasPrice) ?? 0),
                yEnd: .value("Price End", Int(avgMin))
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(curGradient)
//            }
        }
        .chartYScale(domain: avgMin...avgMax)
        .animation(.easeIn)
//        .chartXAxis(.hidden)
//        .chartYAxis(.hidden)
    }
}

struct AvgChart_Previews: PreviewProvider {
    static var previews: some View {
        AvgChart()
    }
}

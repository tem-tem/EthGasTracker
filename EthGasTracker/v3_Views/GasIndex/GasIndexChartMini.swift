//
//  GasIndexChartMini.swift
//  EthGasTracker
//
//  Created by Tem on 8/10/23.
//

import SwiftUI
import Charts

struct GasIndexChartMini: View {
    let entries: [GasIndexEntity.ListEntry]
    let min: Float?
    let max: Float?

    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    var body: some View {
        Chart(entries, id: \.index) { entry in
            if (entry.index % 2 == 0) {
                LineMark(
                    x: .value("Time", entry.timestamp),
                    y: .value("Price", isFastMain ? entry.fast : entry.normal)
                )
                .lineStyle(StrokeStyle(lineWidth: 1))
                .foregroundStyle(Gradient(colors: [Color("avg"), Color("avgLight")]))
                
                
                AreaMark(
                    x: .value("Time", entry.timestamp),
                    yStart: .value("Price Start", isFastMain ? entry.fast : entry.normal),
                    yEnd: .value("Price End", min ?? 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient (
                            colors: [
                                Color("avg").opacity(0.5),
                                Color("avg").opacity(0.0),
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartYScale(domain: (min ?? 0)...(max ?? 10))
        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
        .padding(.vertical, 0)
    }
}

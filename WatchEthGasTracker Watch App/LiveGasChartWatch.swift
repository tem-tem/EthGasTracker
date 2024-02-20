//
//  LiveGasChartWatch.swift
//  WatchEthGasTracker Watch App
//
//  Created by Tem on 2/17/24.
//

import SwiftUI
import Charts

struct LiveGasChartWatch: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    
//        @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    var entriesMin: Int {
        Int(round(liveDataVM.gasDataEntity.min)) - 1
    }
    var body: some View {
        Chart(liveDataVM.gasDataEntity.entries, id: \.index) { entry in
            let count = liveDataVM.gasDataEntity.entries.count
            let entryGas = Int(round(entry.normal))
            let lastEntry = liveDataVM.gasDataEntity.entries[count - 1]
            let lastEntryGas = Int(round(lastEntry.normal))
            
            PointMark(
                x: .value("Index", lastEntry.index),
                y: .value("Gas", lastEntryGas)
            )
            .symbolSize(50)
            .foregroundStyle(liveDataVM.gasLevel.color)
//                    .foregroundStyle(primaryColor)
            
            LineMark(
                x: .value("Index", entry.index),
                y: .value("Gas Start", entryGas)
            )
            .lineStyle(StrokeStyle(lineWidth: 1))
            .foregroundStyle(liveDataVM.gasLevel.color)
            
            
            AreaMark(
                x: .value("Index", entry.index),
                yStart: .value("Gas Start", entryGas),
                yEnd: .value("Gas End", entriesMin),
                series: .value("", "Whole")
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [liveDataVM.gasLevel.color.opacity(0.2), liveDataVM.gasLevel.color.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartXAxis(.hidden)
        .chartYScale(domain: (Int(liveDataVM.gasDataEntity.min) - 1)...(Int(liveDataVM.gasDataEntity.max) + 1))
    }
}

#Preview {
    LiveGasChartWatch()
}

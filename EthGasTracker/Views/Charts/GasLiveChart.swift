//
//  GasLiveChart.swift
//  EthGasTracker
//
//  Created by Tem on 1/8/24.
//

import SwiftUI
import Charts
//import Pow

let labeledIndexes = [5, 20, 35, 50, 65, 80]

struct GasLiveChart: View {
    let primaryColor: Color
    let secondaryColor: Color
    @EnvironmentObject var liveDataVM: LiveDataVM
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    var body: some View {
        GasLiveChart_ChartItself(
            primaryColor: primaryColor, secondaryColor: secondaryColor
        )
            .chartOverlay { proxy in
                GasLiveChart_SwipeResolver(
                    proxy: proxy
                )
            }
            .chartYScale(domain: (Int(liveDataVM.gasDataEntity.min) - 1)...(Int(liveDataVM.gasDataEntity.max) + 1))
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
            .frame(maxHeight: CHART_HEIGHT)
            .padding(.horizontal)
    }
}

#Preview {
    GasLiveChart(
        primaryColor: .primary, secondaryColor: .secondary)
        .environmentObject(LiveDataVM(apiManager: APIManager()))
        .environmentObject(ActiveSelectionVM())
}

struct GasLiveChart_ChartItself: View {
    let primaryColor: Color
    let secondaryColor: Color
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    @State private var animationFlags: [Bool] = []
    
    @State private var pulseSize: CGFloat = 10
    
    var entriesMin: Int {
        Int(round(liveDataVM.gasDataEntity.min)) - 1
    }
    
    var body: some View {
        Chart(liveDataVM.gasDataEntity.entries, id: \.index) { entry in
//            if (entry.index % 5 == 0) {
//                ForEach(gridYCoordinates, id: \.self) { y in
//                    PointMark(
//                        x: .value("Index", entry.index),
//                        y: .value("Gas", y)
//                    )
//                    .symbolSize(1)
//                    .foregroundStyle(primaryColor.opacity(0.5))
//                }
//            }
            let count = liveDataVM.gasDataEntity.entries.count
            let entryGas = isFastMain ? Int(round(entry.fast)) : Int(round(entry.normal))
            let lastEntry = liveDataVM.gasDataEntity.entries[count - 1]
            let lastEntryGas = isFastMain ? Int(round(lastEntry.fast)) : Int(round(lastEntry.normal))
            if entry.index == lastEntry.index, activeSelectionVM.date == nil, activeSelectionVM.gas == nil {
                
                PointMark(
                    x: .value("Index", lastEntry.index),
                    y: .value("Gas", lastEntryGas)
                )
                .symbolSize(150)
                .foregroundStyle(Color(.systemBackground))
                
//                PointMark(
//                    x: .value("Index", lastEntry.index),
//                    y: .value("Gas", lastEntry.normal)
//                )
//                .symbolSize(100)
//                .foregroundStyle(liveDataVM.gasLevel.color)
                
                // make this point mark pulse each second (activeSelectionVM.currentTime)
                PointMark(
                    x: .value("Index", lastEntry.index),
                    y: .value("Gas", lastEntryGas)
                )
                .symbolSize(100)
                .foregroundStyle(primaryColor)
                
                RuleMark(
                    x: .value("Index", lastEntry.index),
                    yStart: .value("Gas", lastEntryGas),
                    yEnd: .value("Gas", entriesMin)
                )
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .foregroundStyle(primaryColor)
            }
            
            PointMark(
                x: .value("Index", lastEntry.index),
                y: .value("Gas", lastEntryGas)
            )
            .symbolSize(20)
            .foregroundStyle(primaryColor)
            
            RuleMark(
                xStart: .value("Index", 0),
                xEnd: .value("Index", lastEntry.index),
                y: .value("Gas", lastEntryGas)
            )
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [1, 10]))
            .foregroundStyle(primaryColor)
            
            RuleMark(
                x: .value("Index", entry.index),
                yStart: .value("Gas", entryGas),
                yEnd: .value("Gas", entriesMin)
            )
                .lineStyle(StrokeStyle(lineWidth: 1))
                .foregroundStyle(secondaryColor)
            
//            RuleMark(
//                x: .value("Index", entry.index),
//                yStart: .value("Gas Start", (liveDataVM.gasIndexEntriesMinMax.min ?? 0) * 1),
//                yEnd: .value("Gas End", liveDataVM.gasIndexEntriesMinMax.min ?? 0)
//            )
//            .lineStyle(StrokeStyle(lineWidth: labeledIndexes.contains(entry.index) ? 1 : 0.5))
//            .foregroundStyle(primaryColor.opacity(0.75))
//            .annotation(position: .bottom) {
//                RoundedRectangle(cornerSize: CGSize(width: 2, height: 2))
//                    .frame(width: 1, height: labeledIndexes.contains(entry.index) ? 15 : 10)
//                    .foregroundStyle(primaryColor.opacity(0.5))
//            }
            
//            LineMark(
//                x: .value("Index", entry.index),
//                y: .value("Gas Start", entryGas)
//            )
//            .lineStyle(StrokeStyle(lineWidth: 1))
//            .foregroundStyle(primaryColor.gradient)
            
//            AreaMark(
//                x: .value("Index", entry.index),
//                yStart: .value("Gas Start", entryGas),
//                yEnd: .value("Gas End", entriesMin),
//                series: .value("", "Whole")
//            )
//            .foregroundStyle(
//                LinearGradient(
//                    colors: [secondaryColor.opacity(0.2), secondaryColor.opacity(0)],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//            )
//            .interpolationMethod(.stepCenter)
            
            if let index = activeSelectionVM.index, let gas = activeSelectionVM.gas {
                let selectedGas = Int(round(gas))
//                RuleMark(
//                    xStart: .value("Index", 0),
//                    xEnd: .value("Index", lastEntry.index),
//                    y: .value("Gas", gas)
//                )
//                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
//                .foregroundStyle(liveDataVM.gasLevel.color)
                PointMark(
                    x: .value("Index", index),
                    y: .value("Gas", selectedGas)
                )
                .symbolSize(150)
                .foregroundStyle(Color(.systemBackground))
                
                PointMark(
                    x: .value("Index", index),
                    y: .value("Gas", selectedGas)
                )
                .symbolSize(100)
                .foregroundStyle(primaryColor)
                
                RuleMark(x: .value("Index", index),
                         yStart: .value("Gas", selectedGas),
                         yEnd: .value("Gas", entriesMin))
                .lineStyle(StrokeStyle(lineWidth: 1))
                .foregroundStyle(LinearGradient(colors: [ primaryColor.opacity(1), primaryColor.opacity(0),], startPoint: .top, endPoint: .bottom))
            }
        }
//        .animation(.spring, value: liveDataVM.timestamp)
    }
}

struct GasLiveChart_SwipeResolver: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    var proxy: ChartProxy
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle().fill(.clear).contentShape(Rectangle())
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { value in
                            
                            let origin = geometry[proxy.plotAreaFrame].origin
                            let location = CGPoint(
                                x: value.location.x - origin.x,
                                y: value.location.y - origin.y
                            )
                            guard let index = proxy.value(atX: location.x, as: Int.self) else {
                                return
                            }
                            let clampedIndex = min(max(0, index), liveDataVM.gasDataEntity.entries.count - 2)
                            let entry = liveDataVM.gasDataEntity.entries[clampedIndex]
                            activeSelectionVM.date = entry.date
                            activeSelectionVM.gas = isFastMain ? entry.fast : entry.normal
                            activeSelectionVM.key = entry.key
                            activeSelectionVM.index = clampedIndex
                        }
                        .onEnded { _ in
                            activeSelectionVM.drop()
                        }
                )
        }
    }
}

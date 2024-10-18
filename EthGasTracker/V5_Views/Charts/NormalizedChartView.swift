//
//  StandardizedChartView.swift
//  EthGasTracker
//
//  Created by Tem on 10/10/24.
//
import SwiftUI
import Charts


struct NormalizedChartView: View {
    let entries: [NormilizedChartData]
    let primaryColor: Color
    let secondaryColor: Color
    let entriesMin: Int
    let entriesMax: Int
    var showLastValue: Bool = false
    var lastEntry: NormilizedChartData? { entries.last }
    
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM

    var gradient: Gradient {
        Gradient(colors: [primaryColor.opacity(0.5), primaryColor.opacity(0)])
    }
    
    var safeRange: ClosedRange<Double> {
        let range = Double(entriesMax - entriesMin)
        let padding = range * 0.1
        return (Double(entriesMin) - padding)...(Double(entriesMax) + padding)
    }
    
    var body: some View {
        Chart(entries, id: \.index) { entry in
            LineMark(
                x: .value("Index", entry.index),
                y: .value("Value", Int(entry.value))
            )
            .foregroundStyle(primaryColor)
            .lineStyle(StrokeStyle(lineWidth: 3))
            .interpolationMethod(.catmullRom)
            
            AreaMark(
                x: .value("Index", entry.index),
                yStart: .value("Value", Int(entriesMin)),
                yEnd: .value("Value Min", Int(entry.value))
            )
            .foregroundStyle(gradient)
            .interpolationMethod(.catmullRom)
            
            if showLastValue, let lastEntryToDisplay = lastEntry {
                PointMark(
                    x: .value("Index", lastEntryToDisplay.index),
                    y: .value("Value", Int(lastEntryToDisplay.value))
                )
                .foregroundStyle(primaryColor)
                .symbol() {
                    Circle()
                        .fill(primaryColor)
                        .frame(width: 10)
                }
            }
            
            if let selectedIndex = activeSelectionVM.index,
               let selectedValue = activeSelectionVM.gas,
               let selectedEntry = entries.first(where: { $0.index == selectedIndex }) {
                PointMark(
                    x: .value("Index", selectedEntry.index),
                    y: .value("Value", Int(selectedValue))
                )
                .symbolSize(100)
                .foregroundStyle(primaryColor)
                .symbol() {
                    Circle()
                        .stroke(primaryColor, lineWidth: 2)
                        .frame(width: 10, height: 10)
                }
                
                RuleMark(
                    x: .value("Index", selectedEntry.index)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundStyle(primaryColor)
            }
        }
        .chartYScale(domain: safeRange)
        .chartXAxis(.hidden)
    }
}


//#Preview {
//    let entries = (0..<20).map { index in
//        NormilizedChartData(
//            index: index,
//            value: Double.random(in: 50...100) // Random value between 0 and 100
//        )
//    }
//
//    let entriesMin = entries.map { Int($0.value) }.min() ?? 0
//    let entriesMax = entries.map { Int($0.value) }.max() ?? 1
//
//    PreviewWrapper {
//        NormalizedChartView(
//            entries: entries,
//            primaryColor: .blue,
//            secondaryColor: .green,
//            entriesMin: entriesMin,
//            entriesMax: entriesMax,
//            showLastValue: true
//        )
//    }
//}
#Preview {
    PreviewWrapper {
        V5_ChartView()
    }
}

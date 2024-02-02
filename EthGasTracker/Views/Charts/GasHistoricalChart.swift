//
//  GasHistoricalChart.swift
//  EthGasTracker
//
//  Created by Tem on 1/9/24.
//

import SwiftUI
import Charts

struct GasHistoricalChart: View {
    @AppStorage("subbed") var subbed: Bool = false
    let entries: HistoricalDataCached
    let primaryColor: Color
    let secondaryColor: Color
    
//    @State private var selectedIndex: Int? = nil
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    
    var entriesMinMax: MinMax {
        return entries.safeRanges.normal
    }
    
    var blocked: Bool {
        return activeSelectionVM.chartType != .hour && activeSelectionVM.chartType != .live && !subbed
    }

    var body: some View {
        ZStack {
            if (blocked) {
                VStack {
                    Spacer()
                    SubscriptionView()
                    Spacer()
                }
            } else {
                if (entries.gasListNormal.count > 0) {
                    GasHistorical_ChartItself(
                        entries: entries.gasListNormal,
                        primaryColor: primaryColor, secondaryColor: secondaryColor
                    )
                } else {
                    ProgressView()
                }
            }
        }
        .chartOverlay { proxy in
            if (!blocked) {
                GasHistorical_SwipeResolver(
                    proxy: proxy,
                    entries: entries.gasListNormal
                )
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(maxHeight: CHART_HEIGHT)
        .padding(.horizontal)
        
    }
}

struct GasHistorical_ChartItself: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    let entries: [HistoricalData]
    let primaryColor: Color
    let secondaryColor: Color
    
    var min: Int {
        return ((entries.map { Int(round($0.avg)) }.min() ?? 0) - 1)
    }
    
    var max: Int {
        return (entries.map { Int(round($0.avg)) }.max() ?? 1) + 1
    }
    
    var body: some View {
        Chart(entries, id: \.date) { entry in
            RuleMark(
                x: .value("Time", entry.date),
                yStart: .value("value", Int(round(entry.avg))),
                yEnd: .value("value", min)
            )
            .lineStyle(StrokeStyle(lineWidth: 1))
            .foregroundStyle(secondaryColor)
//            LineMark(
//                x: .value("Time", entry.date),
//                y: .value("value", Int(entry.avg)),
//                series: .value("avg", "C")
//            )
//                .foregroundStyle(primaryColor.gradient)
//                .lineStyle(StrokeStyle(lineWidth: 1))
//            AreaMark(
//                x: .value("Time", entry.date),
//                yStart: .value("value", Int(entry.avg)),
//                yEnd: .value("value", Int(min ?? 0))
//            )
//                .foregroundStyle(LinearGradient(colors: [secondaryColor.opacity(0.2), secondaryColor.opacity(0)], startPoint: .top, endPoint: .bottom))
            if let selection = activeSelectionVM.historicalData {
                let selectinoValue = Int(round(selection.avg))
                RuleMark(
                    x: .value("Time", selection.date),
                    yStart: .value("value", selectinoValue),
                    yEnd: .value("value", min)
                )
                    .foregroundStyle(LinearGradient(colors: [primaryColor.opacity(1), primaryColor.opacity(0)], startPoint: .top, endPoint: .bottom))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                PointMark(
                    x: .value("Time", selection.date),
                    y: .value("value", selectinoValue)
                )
                    .symbolSize(150)
                    .foregroundStyle(Color(.systemBackground))
                PointMark(
                    x: .value("Time", selection.date),
                    y: .value("value", selectinoValue)
                )
                    .foregroundStyle(primaryColor)
                    .symbolSize(100)
            }
//            RuleMark(
//                x: .value("Index", entry.timestamp),
//                yStart: .value("Price Start", entry.avg),
//                yEnd: .value("Price End", min ?? 0)
//            )
//            .lineStyle(StrokeStyle(lineWidth: 0.5))
//            .foregroundStyle(primaryColor.opacity(0.75))
        }
        .chartYScale(domain: min...max)
    }
}

struct GasHistorical_SwipeResolver: View {
    var proxy: ChartProxy
    let entries: [HistoricalData]
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
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
                            guard let index = proxy.value(atX: location.x, as: Date.self) else {
                                return
                            }
                            let closestEntry = entries.enumerated().min { lhs, rhs in
                                abs(lhs.element.date.timeIntervalSince(index)) < abs(rhs.element.date.timeIntervalSince(index))
                            }
                            guard let entry = closestEntry else {
                                return
                            }
                            activeSelectionVM.historicalData = entry.element
//
                        }
                        .onEnded { _ in
                            activeSelectionVM.drop()
                        }
                )
        }
    }
}

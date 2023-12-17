//
//  GasIndexChartFocus.swift
//  EthGasTracker
//
//  Created by Tem on 8/20/23.
//

import SwiftUI
import Charts

struct GasIndexChartHistorical: View {
    @AppStorage("subbed") var subbed: Bool = false
    @EnvironmentObject var appDelegate: AppDelegate
    let entries: HistoricalDataCahced
    @Binding var selectedHistoricalData: HistoricalData?
    
    @State private var selectedIndex: Int? = nil

    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    let primaryColor = Color.primary
    
    var entriesMinMax: MinMax {
        return entries.safeRanges.normal
    }

    var body: some View {
        ZStack {
            ChartItselfHistorical(
                entries: entries.gasListNormal, // Using the flattened data
                min: entriesMinMax.min * 0.95,
                max: entriesMinMax.max,
                selectedHistoricalData: $selectedHistoricalData
            )
            .blur(radius: subbed ? 0 : 10)
            Color.clear.allowsHitTesting(!subbed)
//            .blur(radius: subbed ? 0 : 10)
            if (!subbed) {
                SubscriptionView()
            }
        }
        .chartOverlay { proxy in
            if (subbed) {
                SwipeResolverHistorical(
                    proxy: proxy,
                    entries: entries.gasListNormal,
                    selectedHistoricalData: $selectedHistoricalData
                )
            }
        }
        .chartYScale(domain: (entriesMinMax.min * 0.95)...(entriesMinMax.max))
        .chartXAxis(.hidden)
//        .chartXAxis{
//            AxisMarks(values: [0, 10, 20, 30, 40, 50, 60, 70, 80]) { value in
//                AxisValueLabel {
//                    if let index = value.as(Int.self),
//                       entries.count > index {
//                        let entry = entries[index]
//                        Text(entry.timestamp, format: .dateTime.hour(.defaultDigits(amPM: .omitted))) +
//                        Text(":") +
//                        Text(entry.timestamp, format: .dateTime.minute(.twoDigits))
////                                .foregroundColor(selectedKey != nil ? .secondary : appDelegate.gasLevel.color)
//                    }
//                }.font(.caption2)
//            }
//        }
        .padding(.horizontal)
    }
}

struct ChartItselfHistorical: View {
    @EnvironmentObject var appDelegate: AppDelegate
    let entries: [HistoricalData] // Adjusted to a linear array
    let min: Float?
    let max: Float?
    @Binding var selectedHistoricalData: HistoricalData?

    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    let primaryColor = Color.primary
    
    var body: some View {
        Chart(entries, id: \.date) { entry in
            LineMark(x: .value("Time", entry.date), y: .value("value", entry.avg))
                .foregroundStyle(appDelegate.gasLevel.color.gradient)
            AreaMark(x: .value("Time", entry.date), yStart: .value("value", entry.avg), yEnd: .value("value", min ?? 0))
                .foregroundStyle(LinearGradient(colors: [appDelegate.gasLevel.color.opacity(0.5), appDelegate.gasLevel.color.opacity(0)], startPoint: .top, endPoint: .bottom))
            if let selection = selectedHistoricalData {
                PointMark(x: .value("Time", selection.date), y: .value("value", selection.avg))
                    .symbolSize(150)
                    .foregroundStyle(Color(.systemBackground))
                PointMark(x: .value("Time", selection.date), y: .value("value", selection.avg))
                    .foregroundStyle(appDelegate.gasLevel.color)
                    .symbolSize(100)
                RuleMark(x: .value("Time", selection.date), yStart: .value("value", selection.avg), yEnd: .value("value", min ?? 0))
                    .foregroundStyle(appDelegate.gasLevel.color)
                    .lineStyle(StrokeStyle(lineWidth: 1))
            }
//            RuleMark(
//                x: .value("Index", entry.timestamp),
//                yStart: .value("Price Start", entry.avg),
//                yEnd: .value("Price End", min ?? 0)
//            )
//            .lineStyle(StrokeStyle(lineWidth: 0.5))
//            .foregroundStyle(primaryColor.opacity(0.75))
        }
    }
}

struct SwipeResolverHistorical: View {
    var proxy: ChartProxy
    let entries: [HistoricalData]
    @Binding var selectedHistoricalData: HistoricalData?
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
                            selectedHistoricalData = entry.element
//
                        }
                        .onEnded { _ in
                            selectedHistoricalData = nil
                        }
                )
        }
    }
}

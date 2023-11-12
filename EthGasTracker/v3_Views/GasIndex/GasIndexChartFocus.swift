//
//  GasIndexChartFocus.swift
//  EthGasTracker
//
//  Created by Tem on 8/20/23.
//

import SwiftUI
import Charts

struct GasIndexChartFocus: View {
    @EnvironmentObject var appDelegate: AppDelegate
    let entries: [GasIndexEntity.ListEntry]
    let min: Float?
    let max: Float?
    @Binding var selectedDate: Date?
    @Binding var selectedPrice: Float?
    @Binding var selectedKey: String?
    
    @State private var selectedIndex: Int? = nil

    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    let primaryColor = Color.primary
    
    var body: some View {
        VStack {
            ChartItself(
                entries: entries,
                min: (min ?? 1),
                max: (max ?? 1),
                selectedDate: $selectedDate,
                selectedPrice: $selectedPrice,
                selectedIndex: $selectedIndex
            )
            .chartOverlay { proxy in
                SwipeResolver(
                    proxy: proxy,
                    entries: entries,
                    selectedDate: $selectedDate,
                    selectedPrice: $selectedPrice,
                    selectedKey: $selectedKey,
                    selectedIndex: $selectedIndex
                )
            }
            .chartYScale(domain: (min ?? 0)...(max ?? 10))
            .chartYAxis(.hidden)
            .chartXAxis{
                AxisMarks(values: [0, 10, 20, 30, 40, 50, 60, 70, 80]) { value in
                    AxisValueLabel {
                        if let index = value.as(Int.self),
                           entries.count > index {
                            let entry = entries[index]
                            Text(entry.timestamp, format: .dateTime.hour(.defaultDigits(amPM: .omitted))) +
                            Text(":") +
                            Text(entry.timestamp, format: .dateTime.minute(.twoDigits))
//                                .foregroundColor(selectedKey != nil ? .secondary : appDelegate.gasLevel.color)
                        }
                    }.font(.caption2)
                }
            }
            .padding(.vertical, 0)
            .padding(.trailing)
        }
    }
}

struct ChartItself: View {
    @EnvironmentObject var appDelegate: AppDelegate
    let entries: [GasIndexEntity.ListEntry]
    let min: Float?
    let max: Float?
    @Binding var selectedDate: Date?
    @Binding var selectedPrice: Float?
    
    @Binding var selectedIndex: Int?

    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    let primaryColor = Color.primary
    
    var body: some View {
        Chart(entries, id: \.index) { entry in
            let count = entries.count
            let lastEntry = entries[count - 1]
            if entry.index == lastEntry.index, selectedDate == nil, selectedPrice == nil {
                PointMark(
                    x: .value("Index", lastEntry.index),
                    y: .value("Price", lastEntry.normal)
                )
                .symbolSize(150)
                .foregroundStyle(Color(.systemBackground))

                PointMark(
                    x: .value("Index", lastEntry.index),
                    y: .value("Price", lastEntry.normal)
                )
                .symbolSize(100)
                .foregroundStyle(appDelegate.gasLevel.color)
                
                RuleMark(
                    x: .value("Index", entry.index),
                    yStart: .value("Price Start", isFastMain ? entry.fast : entry.normal),
                    yEnd: .value("Price End", min ?? 0)
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
//                .foregroundStyle(Color(.systemRed))
                .foregroundStyle(appDelegate.gasLevel.color)
            } else {
                RuleMark(
                    x: .value("Index", entry.index),
                    yStart: .value("Price Start", isFastMain ? entry.fast : entry.normal),
                    yEnd: .value("Price End", min ?? 0)
                )
                .lineStyle(StrokeStyle(lineWidth: 0.5))
                .foregroundStyle(primaryColor.opacity(0.75))
//                .foregroundStyle(selectedIndex != nil ? primaryColor.opacity(0.75) : appDelegate.gasLevel.color.opacity(0.75))
            }
            

            if (selectedIndex != nil && selectedPrice != nil) {
                
                PointMark(
                    x: .value("Index", selectedIndex!),
                    y: .value("Price", selectedPrice!)
                )
                .symbolSize(150)
                .foregroundStyle(Color(.systemBackground))

                PointMark(
                    x: .value("Index", selectedIndex!),
                    y: .value("Price", selectedPrice!)
                )
                .symbolSize(100)
                .foregroundStyle(primaryColor)
                
                RuleMark(x: .value("Index", selectedIndex!),
                         yStart: .value("Price", selectedPrice!),
                         yEnd: .value("Price", min ?? 0))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(primaryColor)
            }
        }
    }
}

struct SwipeResolver: View {
    var proxy: ChartProxy
    let entries: [GasIndexEntity.ListEntry]
    @Binding var selectedDate: Date?
    @Binding var selectedPrice: Float?
    @Binding var selectedKey: String?
    
    @Binding var selectedIndex: Int?
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
                            let clampedIndex = min(max(0, index), entries.count - 2)
                            let entry = entries[clampedIndex]
                            selectedDate = entry.timestamp
                            selectedPrice = isFastMain ? entry.fast : entry.normal
                            selectedKey = entry.key
                            selectedIndex = clampedIndex
                        }
                        .onEnded { _ in
                            selectedDate = nil
                            selectedIndex = nil
                            selectedPrice = nil
                            selectedKey = nil
                        }
                )
        }
    }
}

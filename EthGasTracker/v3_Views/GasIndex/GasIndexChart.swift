//
//  ActionChart.swift
//  EthGasTracker
//
//  Created by Tem on 8/8/23.
//

import SwiftUI
import Charts

struct GasIndexChart: View {
    let entries: [GasIndexEntity.ListEntry]
    let min: Float?
    let max: Float?
    @Binding var selectedDate: Date?
    @Binding var selectedPrice: Float?
    
    @State private var selectedIndex: Int? = nil
    @State private var isDragging = false

    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    
    var body: some View {
        VStack {
            Chart(entries, id: \.index) { entry in
                if let firstEntry = entries[0] {
                    RuleMark(
                        y: .value("Price", firstEntry.normal)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color(.systemGray).opacity(0.2))
                }

                LineMark(
                    x: .value("Time", entry.timestamp),
                    y: .value("Price", isFastMain ? entry.fast : entry.normal)
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.cardinal)
                .foregroundStyle(
                    Gradient(
                        colors: [
                            Color(selectedDate != nil ? "low" : "avg"),
                            Color(selectedDate != nil ? "lowLight" : "avgLight")
                        ]
                    )
                )
                
                
                AreaMark(
                    x: .value("Time", entry.timestamp),
                    yStart: .value("Price Start", isFastMain ? entry.fast : entry.normal),
                    yEnd: .value("Price End", min ?? 0)
                )
                .interpolationMethod(.cardinal)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient (
                            colors: [
                                Color(selectedDate != nil ? "low" : "avg").opacity(0.5),
                                Color(selectedDate != nil ? "lowLight" : "avgLight").opacity(0.0),
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                if (selectedDate != nil && selectedPrice != nil) {

                    RuleMark(x: .value("Time", selectedDate!))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                        .foregroundStyle(Color("low"))
                    PointMark(
                        x: .value("Time", selectedDate!),
                        y: .value("Price", selectedPrice!)
                    )
                    .symbolSize(150)
                    .foregroundStyle(Color(.systemBackground))

                    PointMark(
                        x: .value("Time", selectedDate!),
                        y: .value("Price", selectedPrice!)
                    )
                    .symbolSize(100)
                    .foregroundStyle(Color("low"))
                }
            }
            .chartOverlay { proxy in
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
                                    guard let date = proxy.value(atX: location.x, as: Date.self) else {
                                        return
                                    }

                                    guard let entry = entries.min(by: {
                                        return abs(date.timeIntervalSince($0.timestamp)) < abs(date.timeIntervalSince($1.timestamp))
                                    }) else {
                                        return
                                    }
                                    selectedDate = entry.timestamp
                                    selectedPrice = isFastMain ? entry.fast : entry.normal
                                }
                                .onEnded { _ in
                                    selectedDate = nil
                                    selectedIndex = nil
                                    selectedPrice = nil
                                }
                        )
                }
            }
            .chartYScale(domain: (min ?? 0)...(max ?? 10))
            .chartXAxis{
                AxisMarks(values: .stride(by: .minute, count: 2)) { value in
                    if let date = value.as(Date.self) {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        AxisTick(stroke: StrokeStyle(lineWidth: 0.5))

                        AxisValueLabel {
                            Text(date, format: .dateTime.hour(.defaultDigits(amPM: .omitted))) +
                            Text(":") +
                            Text(date, format: .dateTime.minute(.twoDigits))
                        }.font(.caption2)
                    }
                }
            }
            .padding(.vertical, 0)
        }
        
    }
}

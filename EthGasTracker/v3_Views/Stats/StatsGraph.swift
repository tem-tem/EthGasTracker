//
//  StatsGraph.swift
//  EthGasTracker
//
//  Created by Tem on 8/29/23.
//

import SwiftUI
import Charts

struct StatsGraph: View {
    @AppStorage(SettingsKeys().hapticFeedbackEnabled) private var haptic = true
    let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @EnvironmentObject var appDelegate: AppDelegate
    var stats: StatsEntries {
        return appDelegate.stats
    }
    
    @State private var hour = min(max(Calendar.current.component(.hour, from: Date()), 0), 23)

    var hourStatEntry: StatsEntries.Entry {
        guard stats.statsGroupedByHourNormal.count >= (hour-1), stats.statsGroupedByHourNormal.count > 0 else {
            return StatsEntries.Entry(minuteOfDay: 0, max: 0.0, avg: 0, min: 0, measureName: "")
        }
        return stats.statsGroupedByHourNormal[hour]
    }
    
    let primaryColor = Color.primary
    
    var body: some View {
        NavigationView {
            VStack {
                //            HStack {
                //                Text("Average Gas Prices by Hour")
                //                    .bold()
                ////                    .font(.largeTitle)
                ////                    .fontWeight(.bold)
                //                Spacer()
                //            }
                //            .padding(.horizontal)
                //            Divider()
                Spacer()
                
                Text(String(format: "%.2f", hourStatEntry.avg))
                    .font(.system(size: 100, weight: .thin))
                    .padding(.vertical)
//                    .padding(.top, -30)
                Spacer()
                
                
                VStack {
                    //                HStack(alignment: .bottom) {
                    //                    Image(systemName: "clock")
                    //                    Text(String(format: "%02d:00", hour))
                    //                    Text("-")
                    //                    Text(String(format: "%02d:00", hour + 1))
                    //                    Spacer()
                    //                }
                    //                .font(.system(size: 24, weight: .bold, design: .monospaced))
                    
                    //                Divider()
                    
                    HStack {
                        Image(systemName: "arrow.up")
                        Text("Peak Average Gas")
                        Spacer()
                        Text(String(format: "%.2f", hourStatEntry.max))
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                        Text("Fluctuation Range")
                        Spacer()
                        Text(String(format: "%.2f", hourStatEntry.max - hourStatEntry.min))
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "arrow.down")
                        Text("Lowest Average Gas")
                        Spacer()
                        //                    Image(systemName: "arrow.down")
                        Text(String(format: "%.2f", hourStatEntry.min))
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    Divider()
                }
                .padding()
                
                HStack {
                    Image(systemName: "clock")
                    Text(String(format: "%02d:00", hour))
                    Text("-")
                    Text(String(format: "%02d:00", hour == 23 ? 0 : hour + 1))
                }
                .font(.system(.body, design: .monospaced))
                //            .opacity(0)
                
                Spacer()
                
                Chart(stats.statsGroupedByHourNormal, id: \.minuteOfDay) {
                    
                    AreaMark(
                        x: .value("Minute", $0.minuteOfDay),
                        yStart: .value("Avg", stats.avgMin - 5),
                        yEnd: .value("Avg", $0.avg)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [Color(.systemBlue).opacity(0), .accentColor.opacity(0.25), Color(.systemYellow).opacity(0.5), Color(.systemRed)],
                            startPoint: .bottom, endPoint: .top
                        )
                        .opacity(0.5)
                    )
                    
                    LineMark(
                        x: .value("Minute", $0.minuteOfDay),
                        y: .value("Avg", $0.avg)
                    )
                    //                .symbolSize(1)
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [Color(.systemBlue), .accentColor, Color(.systemYellow), Color(.systemRed)],
                            startPoint: .bottom, endPoint: .top
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                    .alignsMarkStylesWithPlotArea()
                    
                    //                if let currentColor = colorForValue(value: Double($0.avg), min: Double(stats.avgMin), max: Double(stats.avgMax)) {
                    //                    BarMark(
                    //                        x: .value("Minute", $0.minuteOfDay),
                    //                        yStart: .value("Avg", stats.avgMin - 5),
                    //                        yEnd: .value("Avg", $0.avg)
                    //                    )
                    //                        .interpolationMethod(.catmullRom)
                    //                        .cornerRadius(20)
                    //                        .foregroundStyle(hour == $0.minuteOfDay ? primaryColor : currentColor)
                    //                }
                    //                    .foregroundStyle(
                    //                        .linearGradient(
                    //                            colors: [.green.opacity(0), .yellow.opacity(0.5), .red],
                    //                            startPoint: .bottom, endPoint: .top
                    //                        )
                    //                        .opacity(0.5)
                    //                    )
                    
                    //                if ($0.avg == stats.avgMax) {
                    //                    PointMark(
                    //                        x: .value("Hour", $0.minuteOfDay),
                    //                        y: .value("Avg", stats.avgMax)
                    //                    )
                    //                        .symbolSize(90)
                    //                        .foregroundStyle(.red)
                    //                        .annotation(position: .bottom, alignment: .center) {
                    //                            Text("MAX")
                    //                                .font(.system(.caption, design: .monospaced))
                    //                        }
                    //                }
                    //                if ($0.avg == stats.avgMin) {
                    //                    PointMark(
                    //                        x: .value("Hour", $0.minuteOfDay),
                    //                        y: .value("Avg", stats.avgMin)
                    //                    )
                    //                        .symbolSize(90)
                    //                        .foregroundStyle(.green)
                    //                        .annotation(position: .top, alignment: .center) {
                    //                            Text("MIN")
                    //                                .font(.system(.caption, design: .monospaced))
                    //                        }
                    //                }
                    
                    RuleMark(
                        x: .value("Hour", hour),
                        yStart: .value("Avg", stats.statsGroupedByHourNormal[hour].avg),
                        //                    yStart: .value("Avg", stats.avgMin),
                        yEnd: .value("Avg", stats.avgMax + 1)
                    )
                    .opacity(0.3)
                    .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round, dash: [5]))
                    .foregroundStyle(primaryColor)
                    
                    RuleMark(
                        x: .value("Hour", hour),
                        yStart: .value("Avg", stats.avgMin-5),
                        yEnd: .value("Avg", stats.statsGroupedByHourNormal[hour].avg)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                    .foregroundStyle(primaryColor)
                    
                    PointMark(
                        x: .value("Hour", hour),
                        y: .value("Avg", stats.statsGroupedByHourNormal[hour].avg)
                    )
                    .foregroundStyle(Color(.systemBackground))
                    .symbolSize(200)
                    
                    PointMark(
                        x: .value("Hour", hour),
                        y: .value("Avg", stats.statsGroupedByHourNormal[hour].avg)
                    )
                    .symbolSize(100)
                    .foregroundStyle(primaryColor)
//                    .foregroundStyle(Color.accentColor)
                    
                    //            PointMark(
                    //                x: .value("Minute", $0.minuteOfDay / 60),
                    //                y: .value("Avg", $0.avg)
                    ////                : .value("Max", $0.max),
                    //            )
                    //            .symbolSize(5)
                }
                .frame(maxHeight: 200)
                .padding(.horizontal)
                .padding(.bottom)
                .chartYAxis(.hidden)
                .chartXScale(domain: 0...23)
                .chartYScale(domain: (stats.avgMin - 5)...stats.avgMax)
                .chartXAxis {
                    AxisMarks(values: Array(stride(from: 0, to: 23, by: 3))) { value in
                        AxisTick()
                        if let xValue = value.as(Int.self) {
                            AxisGridLine()
                            AxisValueLabel(centered: false, collisionResolution: .disabled, offsetsMarks: true) {
                                Text(String(format: "%02d:00", xValue))
                            }
                        }
                        //                        .offset(x: -10)
                    }
                }
                //            .chartXAxisLabel()
                //            .chartXAxis(.hidden)
                .chartOverlay { proxy in
                    StatsSwipeResolver(
                        proxy: proxy,
                        hour: $hour
                    )
                }
            }
            .onAppear {
                hour = min(max(Calendar.current.component(.hour, from: Date()), 0), 23)
            }
            
            .onChange(of: hour) { _ in
                if (haptic) {
                    hapticFeedbackGenerator.impactOccurred()
                }
            }
            .navigationTitle("Hourly averages")
        }
    }
}


struct StatsSwipeResolver: View {
    var proxy: ChartProxy
    @Binding var hour: Int
    
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
                            let clampedIndex = min(max(0, index), 23)
                            hour = clampedIndex
                        }
                        .onEnded { _ in
                            hour = Calendar.current.component(.hour, from: Date())
                        }
                )
        }
    }
}

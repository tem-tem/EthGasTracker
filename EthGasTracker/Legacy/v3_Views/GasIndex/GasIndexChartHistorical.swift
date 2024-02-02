////
////  GasIndexChartFocus.swift
////  EthGasTracker
////
////  Created by Tem on 8/20/23.
////
//
//import SwiftUI
//import Charts
//
//struct GasIndexChartHistorical: View {
//    @AppStorage("subbed") var subbed: Bool = false
//    @EnvironmentObject var appDelegate: AppDelegate
//    let entries: HistoricalDataCached
//    @Binding var selectedHistoricalData: HistoricalData?
//    @Binding var activeChartType: ChartTypes
//    
//    @State private var selectedIndex: Int? = nil
//
//    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
//    
//    let primaryColor = Color.primary
//    
//    var entriesMinMax: MinMax {
//        return entries.safeRanges.normal
//    }
//    
//    var blocked: Bool {
//        return activeChartType != .hour && activeChartType != .live && !subbed
//    }
//
//    var body: some View {
//        ZStack {
//            if (blocked) {
//                VStack {
//                    Spacer()
//                    SubscriptionView()
//                    Spacer()
//                }
//            } else {
//                ChartItselfHistorical(
//                    entries: entries.gasListNormal, // Using the flattened data
//                    min: entriesMinMax.min * 0.95,
//                    max: entriesMinMax.max,
//                    selectedHistoricalData: $selectedHistoricalData
//                )
//            }
//        }
//        .chartOverlay { proxy in
//            if (!blocked) {
//                SwipeResolverHistorical(
//                    proxy: proxy,
//                    entries: entries.gasListNormal,
//                    selectedHistoricalData: $selectedHistoricalData
//                )
//            }
//        }
//        .chartYScale(domain: (entriesMinMax.min * 0.95)...(entriesMinMax.max))
//        .chartXAxis(.hidden)
//        .padding(.horizontal)
//    }
//}
//
//struct ChartItselfHistorical: View {
//    @EnvironmentObject var appDelegate: AppDelegate
//    let entries: [HistoricalData] // Adjusted to a linear array
//    let min:Double?
//    let max:Double?
//    @Binding var selectedHistoricalData: HistoricalData?
//
//    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
//    
//    let primaryColor = Color.primary
//    
//    var body: some View {
//        Chart(entries, id: \.date) { entry in
//                if #available(iOS 16.4, *) {
//                    LineMark(x: .value("Time", entry.date), y: .value("value", entry.avg), series: .value("avg", "C"))
//                        .foregroundStyle(appDelegate.gasLevel.color.gradient)
//                        .lineStyle(StrokeStyle(lineWidth: 2))
////                        .interpolationMethod(.catmullRom)
////                        .shadow(color: appDelegate.gasLevel.color.opacity(0.5), radius: 50, x: 0, y: 0)
////                        .shadow(color: appDelegate.gasLevel.color.opacity(0.5), radius: 20, x: 0, y: 0)
////                        .shadow(color: appDelegate.gasLevel.color.opacity(0.8), radius: 5, x: 0, y: 0)
//                } else {
//                    LineMark(x: .value("Time", entry.date), y: .value("value", entry.avg), series: .value("avg", "C"))
//                        .foregroundStyle(appDelegate.gasLevel.color.gradient)
//                        .lineStyle(StrokeStyle(lineWidth: 2))
////                        .interpolationMethod(.catmullRom)
//                }
//            AreaMark(x: .value("Time", entry.date), yStart: .value("value", entry.avg), yEnd: .value("value", min ?? 0))
//                .foregroundStyle(LinearGradient(colors: [appDelegate.gasLevel.color.opacity(0.5), appDelegate.gasLevel.color.opacity(0)], startPoint: .top, endPoint: .bottom))
//            if let selection = selectedHistoricalData {
//                RuleMark(x: .value("Time", selection.date), yStart: .value("value", selection.avg), yEnd: .value("value", min ?? 0))
//                    .foregroundStyle(LinearGradient(colors: [appDelegate.gasLevel.color.opacity(1), appDelegate.gasLevel.color.opacity(0.2), appDelegate.gasLevel.color.opacity(0)], startPoint: .top, endPoint: .bottom))
//                    .lineStyle(StrokeStyle(lineWidth: 1))
//                PointMark(x: .value("Time", selection.date), y: .value("value", selection.avg))
//                    .symbolSize(150)
//                    .foregroundStyle(Color(.systemBackground))
//                PointMark(x: .value("Time", selection.date), y: .value("value", selection.avg))
//                    .foregroundStyle(appDelegate.gasLevel.color.gradient)
//                    .symbolSize(100)
//            }
////            RuleMark(
////                x: .value("Index", entry.timestamp),
////                yStart: .value("Price Start", entry.avg),
////                yEnd: .value("Price End", min ?? 0)
////            )
////            .lineStyle(StrokeStyle(lineWidth: 0.5))
////            .foregroundStyle(primaryColor.opacity(0.75))
//        }
//    }
//}
//
//struct SwipeResolverHistorical: View {
//    var proxy: ChartProxy
//    let entries: [HistoricalData]
//    @Binding var selectedHistoricalData: HistoricalData?
//    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
//    
//    var body: some View {
//        GeometryReader { geometry in
//            Rectangle().fill(.clear).contentShape(Rectangle())
//                .highPriorityGesture(
//                    DragGesture()
//                        .onChanged { value in
//
//                            let origin = geometry[proxy.plotAreaFrame].origin
//                            let location = CGPoint(
//                                x: value.location.x - origin.x,
//                                y: value.location.y - origin.y
//                            )
//                            guard let index = proxy.value(atX: location.x, as: Date.self) else {
//                                return
//                            }
//                            let closestEntry = entries.enumerated().min { lhs, rhs in
//                                abs(lhs.element.date.timeIntervalSince(index)) < abs(rhs.element.date.timeIntervalSince(index))
//                            }
//                            guard let entry = closestEntry else {
//                                return
//                            }
//                            selectedHistoricalData = entry.element
////
//                        }
//                        .onEnded { _ in
//                            selectedHistoricalData = nil
//                        }
//                )
//        }
//    }
//}

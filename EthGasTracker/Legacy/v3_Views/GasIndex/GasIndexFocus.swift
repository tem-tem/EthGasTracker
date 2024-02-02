////
////  GasIndexFocus.swift
////  EthGasTracker
////
////  Created by Tem on 8/20/23.
////
//import Charts
//import SwiftUI
//
//struct GasIndexFocus: View {
//    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
//    @EnvironmentObject var appDelegate: AppDelegate
//    
//    @Binding var selectedDate: Date?
//    @Binding var selectedPrice:Double?
//    @Binding var selectedHistoricalData: HistoricalData?
//    var isActiveSelection: Bool
//    var activeChartType: ChartTypes
////    
////    var activeHistData: HistoricalDataCached? {
////        var activeHistoricalData: HistoricalDataCached
////        switch (activeChartType) {
////        case .hour:
////            activeHistoricalData = appDelegate.historicalData_1h
////        case .day:
////            activeHistoricalData = appDelegate.historicalData_1d
////        case .week:
////            activeHistoricalData = appDelegate.historicalData_1w
////        case .month:
////            activeHistoricalData = appDelegate.historicalData_1m
////        default:
////            return nil
////        }
////        return activeHistoricalData
////    }
//    
//    var chartSafeRanges: MinMax? {
//        guard let histData = activeHistData else {
//            return nil
//        }
//        return histData.fullRanges.normal
//    }
//    
//    var deviationRange: MinMax? {
//        guard let histData = activeHistData else {
//            return nil
//        }
//        let deviationList = histData.gasListNormal.map({ $0.deviation })
//        return MinMax(min:Double(deviationList.min() ?? 0), max:Double(deviationList.max() ?? 1))
//    }
//    
//    func getDeviationLevel(for deviation:Double, in range: MinMax) -> String {
//        let rangeSize = range.max - range.min
//        let midpoint = range.min + rangeSize / 2
//        let deviationPercentage = (abs(deviation - midpoint) / rangeSize) * 200
//
//        switch deviationPercentage {
//        case 0..<33.33:
//            return "LOW"
//        case 33.33..<66.67:
//            return "MID"
//        default:
//            return "HIGH"
//        }
//    }
//
//
//
//    var gasValue:Double {
//        if let selectedPrice = selectedPrice {
//            return selectedPrice
//        }
//        if let selectedHistoricalData = selectedHistoricalData {
//            return selectedHistoricalData.avg
//        }
//        return appDelegate.gasLevel.currentGas
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack (spacing: 10) {
//                if (selectedHistoricalData == nil) {
//                    GasScale(selectedPrice: $selectedPrice)
//                        .opacity(.init(isActiveSelection ? 0 : 1))
//                    Spacer()
//                }
//                VStack(spacing: 0) {
//                    Text(String(format: "%.f", gasValue))
//                        .font(.system(size: 60, weight: isActiveSelection ? .thin : .bold, design: .rounded))
//                        .foregroundStyle(
//                            appDelegate.gasLevel.color.gradient
//                                .shadow(.inner(color: .white.opacity(0.5), radius: 2, x: 0, y: 0))
//                        )
//                    if let historicalData = selectedHistoricalData {
//                        HStack {
//                            Spacer()
//                            VStack(alignment: .center) {
//                                Text(getDeviationLevel(for:Double(historicalData.deviation), in: deviationRange!))
//                                    .bold()
//                                Text("DEVIATION").opacity(0.5)
//                            }
//                            .font(.caption)
//                            .padding(.top, 7).frame(maxHeight: 35)
////                            Range(
////                                value: historicalData.deviation,
////                                range: deviationRange,
////                                color: .init(appDelegate.gasLevel.color.gradient.first!)
////                            )
//                            Spacer()
//                        }
//                        
//                    } else {
//                        HStack {
//                            Spacer()
//                            Image(systemName: "info.circle").opacity(0)
//                            Text("\(appDelegate.gasLevel.label)")
//                            Image(systemName: "info.circle").opacity(0.5)
//                            Spacer()
//                        }
//                            .font(.caption)
//                            .bold()
//                            .padding(.bottom).frame(maxHeight: 35)
//                            .opacity(.init(isActiveSelection ? 0 : 1))
//                    }
//                }
//                if (selectedHistoricalData == nil) {
//                    Spacer()
//                    GasScale(selectedPrice: $selectedPrice)
//                        .opacity(.init(isActiveSelection ? 0 : 1))
//                }
//            }
//            .foregroundColor(.init(isActiveSelection ? .primary : appDelegate.gasLevel.color))
//            .padding(.horizontal,20)
//            .cornerRadius(10)
//            .overlay(
//                ZStack {
//                    if let historicalData = selectedHistoricalData, let domainRange = chartSafeRanges {
//                        Chart {
//                            RuleMark(xStart: .value("percentile", 0), xEnd: .value("percentile", 100), y: .value("gas", historicalData.avg))
//                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
//                    //            .foregroundStyle(Color(.secondaryLabel).opacity(0.5))
//                                .foregroundStyle(LinearGradient(colors: [appDelegate.gasLevel.color.opacity(1),appDelegate.gasLevel.color.opacity(0),appDelegate.gasLevel.color.opacity(1)], startPoint: .leading, endPoint: .trailing))
//                            createAreaMark(percentile: 0, gasValue: historicalData.avg, start: historicalData.avg)
//                            createAreaMark(percentile: 5, gasValue: historicalData.p5, start: historicalData.avg)
//                            createAreaMark(percentile: 25, gasValue: historicalData.p25, start: historicalData.avg)
//                            createAreaMark(percentile: 50, gasValue: historicalData.avg, start: historicalData.avg)
//                            createAreaMark(percentile: 75, gasValue: historicalData.p75, start: historicalData.avg)
//                            createAreaMark(percentile: 95, gasValue: historicalData.p95, start: historicalData.avg)
//                            createAreaMark(percentile: 100, gasValue: historicalData.avg, start: historicalData.avg)
//                            
//                            createLineMark(percentile: 0, gasValue: historicalData.avg)
//                            createLineMark(percentile: 5, gasValue: historicalData.p5)
//                            createLineMark(percentile: 25, gasValue: historicalData.p25)
//                            createLineMark(percentile: 50, gasValue: historicalData.avg)
//                            createLineMark(percentile: 75, gasValue: historicalData.p75)
//                            createLineMark(percentile: 95, gasValue: historicalData.p95)
//                            createLineMark(percentile: 100, gasValue: historicalData.avg)
//                            
//                            createRuleMark(percentile: 5, min: domainRange.min, max: domainRange.max, gasValue: historicalData.p5)
//                                .opacity(0.5)
//                            createRuleMark(percentile: 25, min: domainRange.min, max: domainRange.max, gasValue: historicalData.p25)
////                            createRuleMark(percentile: 50, min: domainRange.min, max: domainRange.max, gasValue: historicalData.avg)
//                            createRuleMark(percentile: 75, min: domainRange.min, max: domainRange.max, gasValue: historicalData.p75)
//                            createRuleMark(percentile: 95, min: domainRange.min, max: domainRange.max, gasValue: historicalData.p95)
//                                .opacity(0.5)
//                            if #available(iOS 16.4, *) {
//                                createPointMark(percentile: 5, gasValue: historicalData.p5)
//                                    .shadow(color: appDelegate.gasLevel.color, radius: 10, x: 0, y: 0)
//                                createPointMark(percentile: 25, gasValue: historicalData.p25)
//                                    .shadow(color: appDelegate.gasLevel.color, radius: 10, x: 0, y: 0)
//                                
////                                createPointMark(percentile: 50, gasValue: historicalData.avg)
////                                    .shadow(color: appDelegate.gasLevel.color, radius: 5, x: 0, y: 0)
//                                createPointMark(percentile: 75, gasValue: historicalData.p75)
//                                    .shadow(color: appDelegate.gasLevel.color, radius: 10, x: 0, y: 0)
//                                createPointMark(percentile: 95, gasValue: historicalData.p95)
//                                    .shadow(color: appDelegate.gasLevel.color, radius: 10, x: 0, y: 0)
//                            } else {
//                                createPointMark(percentile: 5, gasValue: historicalData.p5)
//                                createPointMark(percentile: 25, gasValue: historicalData.p25)
////                                createPointMark(percentile: 50, gasValue: historicalData.avg)
//                                createPointMark(percentile: 75, gasValue: historicalData.p75)
//                                createPointMark(percentile: 95, gasValue: historicalData.p95)
//                            }
//                        }
//                        .chartYScale(domain: domainRange.min...domainRange.max)
//                        .chartXScale(domain: 0...100)
//                        .chartXAxis(.hidden)
//                        .chartYAxis(.hidden)
////                        .blendMode(.lighten)
//                        
//
//                    }
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(LinearGradient(colors: [appDelegate.gasLevel.color, appDelegate.gasLevel.color.opacity(0.5)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
//                        .background(appDelegate.gasLevel.color.opacity(0.01))
//                        .background(
//                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .top)
//                        )
//                        .background(
//                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .bottom)
//                        )
//                        .background(
//                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .topTrailing)
//                        )
//                        .background(
//                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .topLeading)
//                        )
//                        .background(
//                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0.1), appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0)]), startPoint: .leading, endPoint: .trailing)
//                        )
//                        .background(
//                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0),appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.1)]), startPoint: .leading, endPoint: .trailing)
//                        )
//                        .opacity(.init(isActiveSelection ? 0 : 1))
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                }
//            )
//        }
//    }
//    
//    func createPointMark(percentile: Int, gasValue:Double) -> some ChartContent {
//        PointMark(
//            x: .value("percentile", percentile),
//            y: .value("gas", gasValue)
//        )
//        .symbolSize(percentile < 25 || percentile > 75 ? 20 : 40)
//        .foregroundStyle(appDelegate.gasLevel.color.gradient)
//    }
//    func createAreaMark(percentile: Int, gasValue:Double, start:Double) -> some ChartContent {
//        AreaMark(x: .value("percentile", percentile), yStart: .value("gas", start), yEnd: .value("gas", gasValue))
//            .foregroundStyle(
//                LinearGradient(
//                    colors: [appDelegate.gasLevel.color.opacity(0.5), appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.5)],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//            )
//            .interpolationMethod(.catmullRom)
//    }
//    func createLineMark(percentile: Int, gasValue:Double) -> some ChartContent {
//        LineMark(x: .value("percentile", percentile), y: .value("gas", gasValue))
//            .foregroundStyle(
//                LinearGradient(
//                    colors: [appDelegate.gasLevel.color.opacity(0.5), appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.5)],
//                    startPoint: .leading,
//                    endPoint: .trailing
//                )
//            )
//            .interpolationMethod(.catmullRom)
//    }
//    
//    func createRuleMark(percentile: Int, min minValue:Double, max maxValue:Double, gasValue:Double) -> some ChartContent {
//        RuleMark(x: .value("percentile", percentile), yStart: .value("gas", minValue), yEnd: .value("gas", maxValue))
//            .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
////            .foregroundStyle(Color(.secondaryLabel).opacity(0.5))
//            .foregroundStyle(LinearGradient(colors: [appDelegate.gasLevel.color.opacity(0),appDelegate.gasLevel.color.opacity(1),appDelegate.gasLevel.color.opacity(0)], startPoint: .top, endPoint: .bottom))
//            .annotation(position: percentile < 50 ? .bottomTrailing : .bottomLeading,
//                        alignment: .center,
//                        spacing: 10) {
//                VStack(alignment: percentile < 50 ? .leading : .trailing) {
//                    Text(String(format: "%.f", gasValue)).bold()
//                        .foregroundStyle(appDelegate.gasLevel.color)
//                    Text("\(percentile)%").foregroundStyle(.secondary)
//                }
//                    .font(.caption)
//                    .offset(x: 0, y: -40)
//            }
//    }
//}
//
//struct GasIndexFocus_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewWrapper {
//            GasIndexFocus(selectedDate: .constant(nil), selectedPrice: .constant(nil), selectedHistoricalData: .constant(nil), isActiveSelection: false, activeChartType: ChartTypes.live)
//        }
//    }
//}

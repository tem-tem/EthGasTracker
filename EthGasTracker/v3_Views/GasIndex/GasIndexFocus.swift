//
//  GasIndexFocus.swift
//  EthGasTracker
//
//  Created by Tem on 8/20/23.
//
import Charts
import SwiftUI

struct GasIndexFocus: View {
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @EnvironmentObject var appDelegate: AppDelegate
    
    @Binding var selectedDate: Date?
    @Binding var selectedPrice: Float?
    @Binding var selectedHistoricalData: HistoricalData?
    var isActiveSelection: Bool
    var activeChartType: ChartTypes
    
    var chartSafeRanges: MinMax? {
        switch (activeChartType) {
        case .hour:
            return appDelegate.historicalData_1h.fullRanges.normal
        case .day:
            return appDelegate.historicalData_1d.fullRanges.normal
        case .week:
            return appDelegate.historicalData_1w.fullRanges.normal
        case .month:
            return appDelegate.historicalData_1m.fullRanges.normal
        default:
            return nil
        }
    }
    
    var gasValue: Float {
        if let selectedPrice = selectedPrice {
            return selectedPrice
        }
        if let selectedHistoricalData = selectedHistoricalData {
            return selectedHistoricalData.avg
        }
        return appDelegate.gasLevel.currentGas
    }
    
    func createPointMark(percentile: Int, gasValue: Float) -> some ChartContent {
        PointMark(
            x: .value("percentile", percentile),
            y: .value("gas", gasValue)
        )
        .symbolSize(percentile < 25 || percentile > 75 ? 40 : 120)
        .foregroundStyle(appDelegate.gasLevel.color.gradient)
    }
    func createAreaMark(percentile: Int, gasValue: Float, floor: Float) -> some ChartContent {
        AreaMark(x: .value("percentile", percentile), yStart: .value("gas", floor), yEnd: .value("gas", gasValue))
            .foregroundStyle(
                LinearGradient(
                    colors: [GasLevel.getColor(for: 1).opacity(0.5), GasLevel.getColor(for: 10).opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
    
    func createRuleMark(percentile: Int, min minValue: Float, max maxValue: Float, gasValue: Float) -> some ChartContent {
        RuleMark(x: .value("percentile", percentile), yStart: .value("gas", minValue), yEnd: .value("gas", maxValue))
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
//            .foregroundStyle(Color(.secondaryLabel).opacity(0.5))
            .foregroundStyle(LinearGradient(colors: [appDelegate.gasLevel.color.opacity(0),appDelegate.gasLevel.color.opacity(1),appDelegate.gasLevel.color.opacity(0)], startPoint: .top, endPoint: .bottom))
            .annotation(position: percentile < 50 ? .bottomTrailing : .bottomLeading,
                        alignment: .center,
                        spacing: 10) {
                VStack(alignment: percentile < 50 ? .leading : .trailing) {
                    Text(String(format: "%.f", gasValue)).bold()
                        .foregroundStyle(appDelegate.gasLevel.color)
                    Text("\(percentile)%").foregroundStyle(.secondary)
                }
                    .font(.caption)
                    .offset(x: 0, y: -40)
            }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack (spacing: 10) {
                if (selectedHistoricalData == nil) {
                    GasScale(selectedPrice: $selectedPrice)
                        .opacity(.init(isActiveSelection ? 0 : 1))
                    Spacer()
                }
                VStack(spacing: 0) {
                    Text(String(format: "%.f", gasValue))
                        .font(.system(size: 60, weight: isActiveSelection ? .thin : .bold, design: .rounded))
                        .foregroundStyle(
                            appDelegate.gasLevel.color.gradient
                                .shadow(.inner(color: .white.opacity(0.5), radius: 2, x: 0, y: 0))
                        )
                    HStack {
                        Spacer()
                        Image(systemName: "info.circle").opacity(0)
                        Text("\(appDelegate.gasLevel.label)")
                        Image(systemName: "info.circle").opacity(0.5)
                        Spacer()
                    }
                        .font(.caption)
                        .bold()
                        .padding(.bottom).frame(maxHeight: 35)
                        .opacity(.init(isActiveSelection ? 0 : 1))
                }
                if (selectedHistoricalData == nil) {
                    Spacer()
                    GasScale(selectedPrice: $selectedPrice)
                        .opacity(.init(isActiveSelection ? 0 : 1))
                }
            }
            .foregroundColor(.init(isActiveSelection ? .primary : appDelegate.gasLevel.color))
            .padding(.horizontal,20)
            .cornerRadius(10)
            .overlay(
                ZStack {
                    if let historicalData = selectedHistoricalData, let domainRange = chartSafeRanges {
                        Chart {
//                            createAreaMark(percentile: 0, gasValue: historicalData.p5, floor: domainRange.min)
//                            createAreaMark(percentile: 25, gasValue: historicalData.p25, floor: domainRange.min)
//                            createAreaMark(percentile: 50, gasValue: historicalData.avg, floor: domainRange.min)
//                            createAreaMark(percentile: 75, gasValue: historicalData.p75, floor: domainRange.min)
//                            createAreaMark(percentile: 95, gasValue: historicalData.p95, floor: domainRange.min)
                            createRuleMark(percentile: 5, min: domainRange.min, max: domainRange.max, gasValue: historicalData.p5)
                            createRuleMark(percentile: 25, min: domainRange.min, max: domainRange.max, gasValue: historicalData.p25)
//                            createRuleMark(percentile: 50, min: domainRange.min, max: domainRange.max, gasValue: historicalData.avg)
                            createRuleMark(percentile: 75, min: domainRange.min, max: domainRange.max, gasValue: historicalData.p75)
                            createRuleMark(percentile: 95, min: domainRange.min, max: domainRange.max, gasValue: historicalData.p95)
                            if #available(iOS 16.4, *) {
                                createPointMark(percentile: 5, gasValue: historicalData.p5)
                                    .shadow(color: appDelegate.gasLevel.color, radius: 10, x: 0, y: 0)
                                createPointMark(percentile: 25, gasValue: historicalData.p25)
                                    .shadow(color: appDelegate.gasLevel.color, radius: 10, x: 0, y: 0)
//                                createPointMark(percentile: 50, gasValue: historicalData.avg)
//                                    .shadow(color: appDelegate.gasLevel.color, radius: 5, x: 0, y: 0)
                                createPointMark(percentile: 75, gasValue: historicalData.p75)
                                    .shadow(color: appDelegate.gasLevel.color, radius: 10, x: 0, y: 0)
                                createPointMark(percentile: 95, gasValue: historicalData.p95)
                                    .shadow(color: appDelegate.gasLevel.color, radius: 10, x: 0, y: 0)
                            } else {
                                createPointMark(percentile: 5, gasValue: historicalData.p5)
                                createPointMark(percentile: 25, gasValue: historicalData.p25)
//                                createPointMark(percentile: 50, gasValue: historicalData.avg)
                                createPointMark(percentile: 75, gasValue: historicalData.p75)
                                createPointMark(percentile: 95, gasValue: historicalData.p95)
                            }
                        }
                        .chartYScale(domain: domainRange.min...domainRange.max)
                        .chartXScale(domain: 0...100)
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
//                        .blendMode(.lighten)
                        

                    }
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(LinearGradient(colors: [appDelegate.gasLevel.color, appDelegate.gasLevel.color.opacity(0.5)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                        .background(appDelegate.gasLevel.color.opacity(0.01))
                        .background(
                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .top)
                        )
                        .background(
                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .bottom)
                        )
                        .background(
                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .topTrailing)
                        )
                        .background(
                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .topLeading)
                        )
                        .background(
                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0.1), appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0)]), startPoint: .leading, endPoint: .trailing)
                        )
                        .background(
                            LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0),appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.1)]), startPoint: .leading, endPoint: .trailing)
                        )
                        .opacity(.init(isActiveSelection ? 0 : 1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            )
        }
    }
}

struct GasIndexFocus_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            GasIndexFocus(selectedDate: .constant(nil), selectedPrice: .constant(nil), selectedHistoricalData: .constant(nil), isActiveSelection: false, activeChartType: ChartTypes.live)
        }
    }
}

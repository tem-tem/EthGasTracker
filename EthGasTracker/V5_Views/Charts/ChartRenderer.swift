//
//  ChartRenderer.swift
//  EthGasTracker
//
//  Created by Tem on 10/10/24.
//
import SwiftUI


struct ChartRenderer: View {
    let primaryColor: Color
    let secondaryColor: Color
    let chartType: ChartTypes
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var historicalDataVM: HistoricalDataVM

    var body: some View {
        if let normalizedEntries = getNormalizedEntries(for: chartType) {
            let (entriesMin, entriesMax) = getMinMaxValues(from: normalizedEntries)
            
            NormalizedChartView(
                entries: normalizedEntries,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                entriesMin: entriesMin,
                entriesMax: entriesMax,
                showLastValue: chartType == .live
            )
            .chartOverlay { proxy in
                NormalizedChart_SwipeResolver(proxy: proxy, chartType: chartType)
            }
        } else {
            Text("No data available for \(chartType.rawValue)")
        }
    }
    
    private func getNormalizedEntries(for type: ChartTypes) -> [NormilizedChartData]? {
        print("Getting normalized entries for \(type.rawValue)")
        switch type {
        case .live:
            return normalizeChartData(liveDataVM.gasDataEntity.entries, valueKeyPath: \.normal, indexKeyPath: \.index)
        default:
            if let historicalData = getHistoricalData(for: type) {
                return normalizeChartData(from: historicalData, valueType: .normalGas)
            }
            return nil
        }
    }
    
    private func getHistoricalData(for type: ChartTypes) -> HistoricalDataCached? {
        switch type {
        case .hour: return historicalDataVM.hour
        case .day: return historicalDataVM.day
        case .week: return historicalDataVM.week
        case .month: return historicalDataVM.month
        default: return nil
        }
    }
    
    private func getMinMaxValues(from entries: [NormilizedChartData]) -> (Int, Int) {
        let minValue = entries.map { Int($0.value) }.min() ?? 0
        let maxValue = entries.map { Int($0.value) }.max() ?? 1
        return (minValue, maxValue)
    }
}


#Preview {
    PreviewWrapper {
        ChartRenderer(
            primaryColor: .primary,
            secondaryColor: .secondary,
            chartType: .live
        )
    }
}

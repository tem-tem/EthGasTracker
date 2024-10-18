//
//  V5_ChartsView.swift
//  EthGasTracker
//
//  Created by Tem on 10/10/24.
//

import SwiftUI
import Charts

struct V5_ChartsView: View {
//    let primaryColor: Color
//    let secondaryColor: Color
//    @AppStorage("subbed") var subbed: Bool = false
    
    @AppStorage("subbed", store: UserDefaults(suiteName: "group.TA.EthGas")) var subbed: Bool = false
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var historicalDataVM: HistoricalDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    
    @State private var activeChartType: ChartTypes = .live
    
    var historicalData: HistoricalDataCached? {
        switch activeChartType {
        case .month:
            historicalDataVM.month
        case .week:
            historicalDataVM.week
        case .day:
            historicalDataVM.day
        case .hour:
            historicalDataVM.hour
        case .live:
            nil
        }
    }
    @State private var isLoaded: Bool = false
    
    var body: some View {
        V5_HistoricalChartRendererView(
            entries: historicalData?.gasListNormal ?? [],
            primaryColor: Color.primary,
            secondaryColor: Color.secondary
        )
    }
}

struct V5_HistoricalChartRendererView: View {
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
            LineMark(x: .value("Value", entry.date), y: .value("Timestamp", entry.avg))
        }
    }
}

#Preview {
    PreviewWrapper {
        V5_ChartsView()
    }
}

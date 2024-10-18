//
//  ChartControllerView.swift
//  EthGasTracker
//
//  Created by Tem on 10/10/24.
//
import SwiftUI

struct ChartControllerView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    
    let primaryColor: Color
    let secondaryColor: Color
    let cachedData: HistoricalDataCached
    let valueType: ValueType
    
    var body: some View {
        // Normalize the data based on the specified type
        let normalizedEntries = normalizeChartData(from: cachedData, valueType: valueType)
        let entriesMin = normalizedEntries.map { Int($0.value) }.min() ?? 0
        let entriesMax = normalizedEntries.map { Int($0.value) }.max() ?? 1
        
        NormilizedChartView(
            entries: normalizedEntries,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            entriesMin: entriesMin,
            entriesMax: entriesMax
        )
    }
}


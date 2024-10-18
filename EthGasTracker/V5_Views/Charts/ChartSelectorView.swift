//
//  ChartSelectorView.swift
//  EthGasTracker
//
//  Created by Tem on 10/10/24.
//

import SwiftUI

struct ChartSelectorView: View {
    @Binding var selectedChartType: ChartTypes
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM

    var body: some View {
        Picker("Select Chart", selection: $selectedChartType) {
            ForEach(ChartTypes.allCases, id: \.self) { chartType in
                Text(chartType.rawValue).tag(chartType)
            }
        }
        .pickerStyle(SegmentedPickerStyle()) // Use segmented style for better UI
        .padding()
        .onChange(of: selectedChartType) { chartType in
            print("Selected chart type: \(chartType.rawValue)")
            activeSelectionVM.chartType = chartType
        }
    }
}

#Preview {
    ChartSelectorView(selectedChartType: .constant(.day))
}


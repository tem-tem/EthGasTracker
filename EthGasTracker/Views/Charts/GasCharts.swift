//
//  GasIndexWithPicker.swift
//  EthGasTracker
//
//  Created by Tem on 12/16/23.
//

import SwiftUI

enum ChartTypes: String, CaseIterable {
    case month = "1M"
    case week = "7D"
    case day = "24H"
    case hour = "1H"
    case live = "LIVE"
}

let CHART_HEIGHT = 120.0

struct GasCharts: View {
    let primaryColor: Color
    let secondaryColor: Color
    @AppStorage("subbed") var subbed: Bool = false
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
        VStack(spacing: 20) {
            if let data = historicalData {
                GasHistoricalChart(
                    entries: data,
                    primaryColor: Color.primary,
                    secondaryColor: Color.secondary
                )
            } else {
                GasLiveChart(primaryColor: .primary, secondaryColor: .secondary)
            }
            HStack {
                Spacer()
                ForEach(ChartTypes.allCases, id: \.self) { chartType in
                    let isActive = activeChartType == chartType
                    Button {
                        activeChartType = chartType
                    } label: {
                        HStack {
                            Spacer()
                            Text(chartType.rawValue)
                            if (chartType == .live) {
                                Circle()
                                    .fill(isActive ? primaryColor : secondaryColor)
                                    .frame(width: 8, height: 8)
                            }
                            Spacer()
                        }
                    }
                        .font(.caption)
                        .bold(isActive)
                        .foregroundColor(isActive ? primaryColor : secondaryColor)
                        .padding(.vertical, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isActive ? primaryColor : secondaryColor, lineWidth: isActive ? 2 : 1)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        )
                    Spacer()
                }
            }
            .onChange(of: activeChartType) { chartType in
                activeSelectionVM.chartType = chartType
                switch (chartType) {
                case .hour:
                    historicalDataVM.fetch(range: .hour)
                case .day:
                    if (subbed) {
                        historicalDataVM.fetch(range: .day)
                    }
                case .week:
                    if (subbed) {
                        historicalDataVM.fetch(range: .week)
                    }
                case .month:
                    if (subbed) {
                        historicalDataVM.fetch(range: .month)
                    }
                case .live:
                    return
                }
            }
        }
//        Picker("", selection: $activeChartType) {
//            ForEach(ChartTypes.allCases, id: \.self) { chartType in
//                Text(chartType.rawValue)
//                .font(.caption)
//                .foregroundColor(.accentColor)
//            }
//        }
//        .pickerStyle(.segmented)
//        .padding(.bottom)
//        .padding(.horizontal)
        
//        .onChange(of: historicalData) { data in
////            for (key, dataPoints) in data {
////                print("Timestamp: \(key.timestamp), Measure Name: \(key.measureName)")
//////                for data in dataPoints {
//////                    // Process each 'data' as needed
//////                }
////            }
////            print(data.count)
//
//        }
    }
}

#Preview {
    PreviewWrapper {
        GasCharts(
            primaryColor: .primary, secondaryColor: .secondary
        )
    }
}

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

struct GasIndexWithPicker: View {
    @AppStorage("subbed") var subbed: Bool = false
    @EnvironmentObject var historicalDataVM: HistoricalDataVM
    @Binding var selectedDate: Date?
    @Binding var selectedPrice:Double?
    @Binding var selectedKey: String?
    @Binding var selectedHistoricalData: HistoricalData?
    @Binding var activeChartType: ChartTypes
    
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
    
    var body: some View {
        if let data = historicalData {
            GasIndexChartHistorical(
                entries: data,
                selectedHistoricalData: $selectedHistoricalData,
                activeChartType: $activeChartType
            )
        } else {
            GasLiveChart()
        }
        Picker("", selection: $activeChartType) {
            ForEach(ChartTypes.allCases, id: \.self) { chartType in
                Text(chartType.rawValue)
                .font(.caption)
                .foregroundColor(.accentColor)
            }
        }
        .pickerStyle(.segmented)
        .padding(.bottom)
        .padding(.horizontal)
        .onChange(of: activeChartType) { chartType in
            historicalDataVM.fetch(range: chartType)
//            switch (chartType) {
//            case .hour:
//                appDelegate.fetchHistoricalData_1hr()
//            case .day:
//                if (subbed) {
//                    appDelegate.fetchHistoricalData_day()
//                }
//            case .week:
//                if (subbed) {
//                    appDelegate.fetchHistoricalData_week()
//                }
//            case .month:
//                if (subbed) {
//                    appDelegate.fetchHistoricalData_month()
//                }
//            case .live:
//                return
//            }
        }
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

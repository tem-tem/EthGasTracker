//
//  GasTabView.swift
//  EthGasTracker
//
//  Created by Tem on 8/10/23.
//

import SwiftUI

enum TimeFrame: String, CaseIterable {
    case live = "LIVE"
    case oneHour = "1H"
    case fourHours = "4H"
    case twentyFourHours = "24H"
    case week = "W"
    case month = "M"
    case threeMonths = "3M"

    var fullLengthName: String {
        switch self {
        case .live:
            return "15 minutes"
        case .oneHour:
            return "hour"
        case .fourHours:
            return "4 hours"
        case .twentyFourHours:
            return "24 hours"
        case .week:
            return "week"
        case .month:
            return "month"
        case .threeMonths:
            return "3 months"
        }
    }
}

//// Usage:
//for timeframe in TimeFrame.allCases {
//    print(timeframe.fullLengthName) // This will print the full length names
//}


struct GasTabView: View {
    @AppStorage("isStale") var isStale = false
    @AppStorage("gas.timeframe") var timeframe = TimeFrame.live
//    @State private var selectedTimeframe = "LIVE"
//    let timeframes = ["LIVE", "1H", "4H", "24H", "W", "M", "3M"]
    
    
    var body: some View {
        VStack {
//            GasPriceView().padding()
            GasTrendsView()
                .padding(.horizontal)
                .padding(.bottom)
            Picker("", selection: $timeframe) {
                ForEach(TimeFrame.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
                .padding(.horizontal)
                .padding(.bottom)
                .pickerStyle(.segmented)
//            .padding()
//            HStack {
//                Text("Trends")
//                    .font(.title)
//                    .bold()
//                Spacer()
//            }
//            .padding(.leading)
//                .padding(.horizontal)
        }
        .opacity(isStale ? 0.6 : 1)
        .saturation(isStale ? 0 : 1)
        .animation(.easeInOut(duration: isStale ? 0.5 : 0.1), value: isStale)
    }
}

struct GasTabView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            GasTabView()
        }
    }
}

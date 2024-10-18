//
//  V5_ChartView.swift
//  EthGasTracker
//
//  Created by Tem on 10/10/24.
//
import SwiftUI


struct V5_ChartView: View {
    @State private var selectedChartType: ChartTypes = .live // Default selection
    @AppStorage("subbed", store: UserDefaults(suiteName: "group.TA.EthGas")) var subbed: Bool = false
    @EnvironmentObject var historicalDataVM: HistoricalDataVM

    var body: some View {
        VStack {
            ChartRenderer(
                primaryColor: .blue,
                secondaryColor: .green,
                chartType: selectedChartType
            )
            .id(selectedChartType.rawValue)
            ChartSelectorView(selectedChartType: $selectedChartType)
        }
        .onChange(of: selectedChartType) { chartType in
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
}

#Preview {
    PreviewWrapper {
        V5_ChartView()
    }
}

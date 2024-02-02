//
//  MainGasView.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import SwiftUI

struct MainGasView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    var gas: Double {
        return liveDataVM.gasLevel.currentGas
    }
    var isActiveSelection: Bool {
        activeSelectionVM.isActive()
    }
    
    @State private var showingStats = false
    
    var body: some View {
        VStack {
            ActionsBlockDenseView(
                actions: liveDataVM.actions,
                selectedIndex: activeSelectionVM.index,
                selectedHistoricalData: activeSelectionVM.historicalData
            )
                .padding(.vertical)
                .padding(.horizontal, 5)
            VStack {
                VStack {
                    GasLevelLabel(
                        label: liveDataVM.gasLevel.label,
                        color: liveDataVM.gasLevel.color,
                        level: liveDataVM.gasLevel.level
                    )
                    GasScaleDots(gasLevel: liveDataVM.gasLevel)
                }
                .opacity(isActiveSelection ? 0 : 1)
                .padding(.top, 10)
                .padding(.horizontal, 5)
                Spacer()
                GasIndexView(
                    value: gas,
                    color: liveDataVM.gasLevel.color
                )
                Spacer()
                HStack {
                    TimestampView(timestamp: liveDataVM.timestamp / 1000)
                    Spacer()
                    Button {
                        showingStats.toggle()
                    } label: {
                        Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                            .foregroundStyle(liveDataVM.gasLevel.color)
                    }
                }
                .padding(.horizontal, 15)
                GasCharts(
                    primaryColor: .primary, secondaryColor: .secondary
                )
                .frame(height: CHART_HEIGHT)
                .padding(.bottom, 10)
            }
            .padding(.vertical, 5)
            .background(Color("BG.L1"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 5)
            .sheet(isPresented: $showingStats) {
                StatsGraph()
            }
        }
    }
}

#Preview {
    PreviewWrapper {
        MainGasView()
    }
}

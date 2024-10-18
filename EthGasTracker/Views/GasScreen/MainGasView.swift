//
//  MainGasView.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import SwiftUI

let CHART_HEIGHT = 150.0

struct MainGasView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    @EnvironmentObject var customActionDM: CustomActionDataManager
    
    @State private var isCollapsed = false
    @State private var showingWheel = false
    @State private var showingStats = false
    @State private var showingAlerts = false
    
    var body: some View {
        VStack(spacing: 0) {
            if !isCollapsed {
                ActionsBlockDenseView(
                    actions: customActionDM.pinnedActions,
                    gas: activeSelectionVM.gas ?? liveDataVM.gasLevel.currentGas,
                    ethPrice: activeSelectionVM.ethPrice ?? liveDataVM.ethPrice
                )
                    .padding(.vertical)
                    .padding(.horizontal, 5)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.4)) {
                            isCollapsed.toggle() // Toggle collapsed state
                        }
                    }
            }
            if isCollapsed {
                ActionsManagerView(showingWheel: $showingWheel)
            }
            if showingWheel {
                HWheelPicker()
                    .frame(height: 50)
                    .padding(.horizontal)
            } else {
                GasCardView(isCollapsed: $isCollapsed)
            }
            if !isCollapsed {
                HStack {
                    Button {
                        showingAlerts.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(liveDataVM.gasLevel.color)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.4)) {
                                isCollapsed.toggle() // Toggle collapsed state
                            }
                        }
                    Spacer()
                    Button {
                        showingStats.toggle()
                    } label: {
                        Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                            .foregroundStyle(liveDataVM.gasLevel.color)
                    }
                }
                .sheet(isPresented: $showingStats) {
                    StatsGraph()
                        .background(Color("BG.L1"))
                }
                .sheet(isPresented: $showingAlerts) {
                    MainAlertsView()
                        .background(Color("BG.L1"))
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 20)
                Divider()
            }
        }
    }
}

#Preview {
    PreviewWrapper {
        MainGasView()
            .background(Color("BG.L0"))
    }
}

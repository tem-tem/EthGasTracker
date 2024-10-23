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
//                if showingAverages {
////                        .transition(.move(edge: .trailing))
//                } else {
////                        .transition(.move(edge: .leading))
//                }
            }
            if !isCollapsed {
                ZStack {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.4)) {
                                    isCollapsed.toggle() // Toggle collapsed state
                                }
                            }
                        Spacer()
                    }
                    HStack {
                        Button {
                            showingAlerts.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Alerts")
                            }
                            .foregroundStyle(liveDataVM.gasLevel.color)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(liveDataVM.gasLevel.color, lineWidth: 1)
                            )
                        }
                        Spacer()
                        Button {
                            withAnimation {
                                showingStats.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                                Text("Averages")
                            }
                            .foregroundStyle(liveDataVM.gasLevel.color)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(liveDataVM.gasLevel.color, lineWidth: 1)
                            )
                        }
                    }
                }
                .sheet(isPresented: $showingStats) {
                    VStack(spacing: 0) {
                        Text("Averages")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding()
                        AveragesChartViewController()
                    }
                    .background(Color("BG.L0"))
//                    VStack {
//                        
//                        Button {
//                            showingStats.toggle()
//                        } label: {
//                            HStack {
//                                Spacer()
//                                Image(systemName: "chevron.down")
//                                    .foregroundColor(.secondary)
//                                Spacer()
//                            }
//                            .padding()
//                            .background(Color("BG.L0").opacity(0.5))
//                        }
//                    }
//                    StatsGraph()
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

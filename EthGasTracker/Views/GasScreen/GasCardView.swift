//
//  GasCardView.swift
//  EthGasTracker
//
//  Created by Tem on 2/9/24.
//

import SwiftUI
struct GasCardView: View {
    @Binding var isCollapsed: Bool
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    
    @State private var showingStats = false
    
    var gas: Double {
        liveDataVM.gasLevel.currentGas
    }
    
    var isActiveSelection: Bool {
        activeSelectionVM.isActive()
    }
    
    var body: some View {
        VStack {
            if !isCollapsed {
                HStack {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.4)) {
                                isCollapsed.toggle() // Toggle collapsed state
                            }
                        }
                    Spacer()
                    VStack {
                        GasLevelLabel(
                            label: liveDataVM.gasLevel.label,
                            color: liveDataVM.gasLevel.color,
                            level: liveDataVM.gasLevel.level
                        )
                        GasScaleDots(gasLevel: liveDataVM.gasLevel)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .opacity(0)
                }
                .opacity(isActiveSelection ? 0 : 1)
                .padding(.top, 10)
                .padding(.horizontal, 20)
            }

            Spacer()
            ZStack {
                if isCollapsed {
                    Image(systemName: "chevron.up")
                        .foregroundColor(.secondary)
                }
                HStack {
                    GasIndexView(
                        value: gas,
                        color: liveDataVM.gasLevel.color
                    )
                    .offset(x: isCollapsed ? -70 : 0)
                    .scaleEffect(isCollapsed ? 0.4 : 1)
                    
                    if isCollapsed {
                        Spacer()
                        VStack(alignment: .trailing) {
                            GasLevelLabel(
                                label: liveDataVM.gasLevel.label,
                                color: liveDataVM.gasLevel.color,
                                level: liveDataVM.gasLevel.level
                            )
                            GasScaleDots(gasLevel: liveDataVM.gasLevel)
                        } // Move label to the right when collapsed
                    }
                }
            }
            
            if !isCollapsed {
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
        }
        .padding(.horizontal, isCollapsed ? 10 : 0)
        .padding(.bottom, isCollapsed ? 5 : 0)
        .padding(.vertical, isCollapsed ? 0 : 5)
        .frame(height: isCollapsed ? 50 : nil) // Adjust height when collapsed
        .background(Color("BG.L1"))
        .clipShape(RoundedRectangle(cornerRadius: isCollapsed ? 10 : 20)) // Adjust corner radius when collapsed
        .padding(.horizontal, isCollapsed ? 15 : 5) // Adjust horizontal padding when collapsed
        .sheet(isPresented: $showingStats) {
            StatsGraph()
        }
        .onTapGesture {
            if isCollapsed {
                withAnimation(.spring(duration: 0.4)) {
                    isCollapsed.toggle() // Toggle collapsed state
                }
            }
        }
        .gesture(
            DragGesture().onEnded { value in
                
                let swipeDown = value.translation.height > 0
                let swipeUp = value.translation.height < 0
                if swipeDown && !isCollapsed {
                    withAnimation(.spring(duration: 0.4)) {
                        isCollapsed.toggle() // Toggle collapsed state
                    }
                } else if swipeUp && isCollapsed {
                    withAnimation(.spring(duration: 0.4)) {
                        isCollapsed.toggle() // Toggle collapsed state
                    }
                }
//                if value.translation.height > 0 && abs(value.translation.width) < abs(value.translation.height) {
//                    withAnimation(.easeInOut) {
//                        isCollapsed.toggle() // Toggle collapsed state
//                    }
//                }
            }
        )
    }
}


#Preview {
    PreviewWrapper {
        VStack {
            Spacer()
            GasCardView(isCollapsed: .constant(false))
        }
        .background(Color("BG.L0"))
    }
}

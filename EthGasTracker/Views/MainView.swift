//
//  MainView.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    @EnvironmentObject var alertVM: AlertVM
    
    @AppStorage(SettingsKeys().hapticFeedbackEnabled) private var haptic = true
    let hapticLight = UIImpactFeedbackGenerator(style: .light)
    let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    @State private var selectedTab = 1
    @State private var showingAlertForm = false
    @State private var sheetHeight: CGFloat = .zero
    
    var body: some View {
        ZStack {
            VStack {
                MainHeaderView(showGas: selectedTab != 1)
                TabView(selection: $selectedTab) {
                    MainAlertsView(showingAlertForm: $showingAlertForm)
                        .tag(0)
                    MainGasView()
                        .tag(1)
                    SettingsView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                MainMenuView(selectedTab: $selectedTab, color: liveDataVM.gasLevel.color)
            }
            .background(Color("BG.L0"))
            .onChange(of: activeSelectionVM.index) { _ in
                if (haptic) {
                    hapticLight.impactOccurred()
                }
            }
            .onChange(of: activeSelectionVM.historicalData) { _ in
                if (haptic) {
                    hapticLight.impactOccurred()
                }
            }
            .onChange(of: activeSelectionVM.chartType) { _ in
                if (haptic) {
                    hapticHeavy.impactOccurred()
                }
            }
            .onChange(of: liveDataVM.status) { status in
                if (status == .ok && haptic) {
                    hapticLight.impactOccurred()
                }
            }
            .onChange(of: DeviceTokenManager.shared.deviceToken) { _ in
                alertVM.fetch()
            }
            .sheet(isPresented: $showingAlertForm) {
                AlertFormView(isPresented: $showingAlertForm)
                    .background(Color("BG.L1"))
                    .overlay {
                        GeometryReader { geometry in
                            Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
                        }
                    }
                    .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                        sheetHeight = newHeight
                    }
                    .presentationDetents([.height(500)])
            }
        }
        
    }
}

struct InnerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    PreviewWrapper {
        MainView()
    }
}

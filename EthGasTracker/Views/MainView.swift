//
//  MainView.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import SwiftUI
import AlertToast

struct MainView: View {
    @Binding var showPurchaseSheet: Bool
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    @EnvironmentObject var alertVM: AlertVM
    @EnvironmentObject var alertToastManager: AlertToastManager
    
    @AppStorage("subbed") var subbed: Bool = false
    
    @AppStorage(SettingsKeys().hapticFeedbackEnabled) private var haptic = true
    let hapticLight = UIImpactFeedbackGenerator(style: .light)
    let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    @State private var timer: Timer?
    @State private var selectedTab = 1
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                MainHeaderView(showGas: selectedTab != 0, showBtc: selectedTab != 1, showEth: selectedTab != 0)
                TabView(selection: $selectedTab) {
                    MainBtcView()
                        .tag(0)
                    MainGasView()
                        .tag(1)
                    SettingsView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                MainMenuView(selectedTab: $selectedTab, color: liveDataVM.gasLevel.color)
                    .padding(.horizontal)
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
            .sheet(isPresented: $showPurchaseSheet) {
                PurchaseView()
            }
        }
        .toast(isPresenting: $alertToastManager.isShowing, duration: 5, alert: {
            AlertToast(displayMode: alertToastManager.displayMode, type: alertToastManager.type, title: alertToastManager.message)
        })
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
        MainView(showPurchaseSheet: .constant(false))
    }
}

//
//  MainView.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import SwiftUI
import GoogleMobileAds

struct MainView: View {
    @State var interstitial: GADInterstitialAd?
    @Binding var showPurchaseSheet: Bool
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    @EnvironmentObject var alertVM: AlertVM
    
    @StateObject private var interstitialAdManager = InterstitialAdsManager()
    @AppStorage("subbed") var subbed: Bool = false
    
    @AppStorage(SettingsKeys().hapticFeedbackEnabled) private var haptic = true
    let hapticLight = UIImpactFeedbackGenerator(style: .light)
    let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    @State private var timer: Timer?
    @State private var selectedTab = 1
    
    var body: some View {
        ZStack {
            VStack {
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
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            guard subbed == false else {
                return
            }
            guard interstitialAdManager.loading == false else {
                return
            }
            
            guard interstitialAdManager.interstitialAdLoaded else {
                interstitialAdManager.loadInterstitialAd()
                return
            }
            
            let secondsSinceLastAdShown = Date().timeIntervalSince(interstitialAdManager.lastShownTimestamp)
            
            guard secondsSinceLastAdShown > 180 else {
                return
            }
            
            interstitialAdManager.displayInterstitialAd()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
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

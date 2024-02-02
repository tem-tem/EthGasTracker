////
////  MainView.swift
////  EthGasTracker
////
////  Created by Tem on 8/5/23.
////
//
//import SwiftUI
//import FirebaseAnalytics
//
//struct MainViewLegacy: View {
//    @State var selectedTab = 1
//    @EnvironmentObject var appDelegate: AppDelegate
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            TabView(selection: $selectedTab) {
//                MainFocusView()
//                    .tabItem {
//                        Label("Gas", systemImage: "flame")
//                    }
//                    .tag(1)
//                StatsGraph()
//                    .tabItem {
//                        Label("Averages", systemImage: "chart.bar")
//                    }
//                    .tag(2)
//                AlertsTabView()
//                    .tabItem {
//                        Label("Alerts", systemImage: "bell.badge")
//                    }
//                    .tag(3)
//                SettingsTabView()
//                    .tabItem {
//                        Label("Settings", systemImage: "gear")
//                    }
//                    .tag(4)
//            }
//            .tint(appDelegate.gasLevel.color)
//                .animation(.easeInOut, value: selectedTab)
//                .onChange(of: selectedTab) { newTab in
//                    var tab: String?
//                    switch newTab {
//                    case 2: tab = "statistics"
//                    case 3: tab = "alerts"
//                    case 4: tab = "settings"
//                    default: print("tab-switch")
//                    }
//                    guard let tabName = tab, selectedTab != 0 else {
//                        return
//                    }
//                    let params = [
//                        AnalyticsParameterScreenName: tabName
//                    ]
//                    Analytics.logEvent("tab_switch", parameters: params)
//                }
////            .tabViewStyle(.page)
//        }
//    }
//}
//
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewWrapper {
//            MainViewLegacy()
//        }
//    }
//}

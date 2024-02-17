//
//  PreviewWrapper.swift
//  EthGasTracker
//
//  Created by Tem on 2/16/24.
//

import SwiftUI
import Foundation

struct PreviewWrapper<Content: View>: View {
    let content: Content
    
    
    @StateObject private var activeSelectionVM = ActiveSelectionVM()
    @StateObject private var storeVM = StoreVM()
    @StateObject var networkMonitor = NetworkMonitor()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var customActionDM: CustomActionDataManager
    @StateObject private var liveDataVM: LiveDataVM
    @StateObject private var historicalDataVM: HistoricalDataVM
    @StateObject private var alertVM: AlertVM
    @StateObject private var statsVM: StatsVM
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        
        let apiManager = APIManager()
        let actionDM = CustomActionDataManager()
        _customActionDM = StateObject(wrappedValue: actionDM)
        _liveDataVM = StateObject(wrappedValue: LiveDataVM(apiManager: apiManager, customActionDM: actionDM))
        _historicalDataVM = StateObject(wrappedValue: HistoricalDataVM(apiManager: apiManager))
        _alertVM = StateObject(wrappedValue: AlertVM(apiManager: apiManager))
        _statsVM = StateObject(wrappedValue: StatsVM(apiManager: apiManager))
    }

    var body: some View {
        content
            .environmentObject(appDelegate)
            .environmentObject(liveDataVM)
            .environmentObject(activeSelectionVM)
            .environmentObject(historicalDataVM)
            .environmentObject(storeVM)
            .environmentObject(alertVM)
            .environmentObject(statsVM)
            .environmentObject(customActionDM)
    }
}

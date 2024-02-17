//
//  WatchEthGasTrackerApp.swift
//  WatchEthGasTracker Watch App
//
//  Created by Tem on 2/16/24.
//

import SwiftUI

@main
struct WatchEthGasTracker_Watch_AppApp: App {
    
    @StateObject private var liveDataVM: LiveDataVM
//    @StateObject private var historicalDataVM: HistoricalDataVM
    init() {
        let apiManager = APIManager()
        let actionDM = CustomActionDataManager()
//        _customActionDM = StateObject(wrappedValue: actionDM)
        _liveDataVM = StateObject(wrappedValue: LiveDataVM(apiManager: apiManager, customActionDM: actionDM))
//        _historicalDataVM = StateObject(wrappedValue: HistoricalDataVM(apiManager: apiManager))
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(liveDataVM)
        }
    }
}


struct WatchPreviewWrapper<Content: View>: View {
    let content: Content
    
    @StateObject private var customActionDM: CustomActionDataManager
    @StateObject private var liveDataVM: LiveDataVM
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        
        let apiManager = APIManager()
        let actionDM = CustomActionDataManager()
        _customActionDM = StateObject(wrappedValue: actionDM)
        _liveDataVM = StateObject(wrappedValue: LiveDataVM(apiManager: apiManager, customActionDM: actionDM))
    }

    var body: some View {
        content
            .environmentObject(liveDataVM)
            .environmentObject(customActionDM)
    }
}


//
//  EthGasTrackerWatchApp.swift
//  EthGasTrackerWatch Watch App
//
//  Created by Tem on 2/15/24.
//

import SwiftUI

@main
struct EthGasTrackerWatch_Watch_AppApp: App {
    @StateObject private var liveDataVM: LiveDataVM
    
    init() {
        let apiManager = APIManager()
        let actionDM = CustomActionDataManager()
        let liveDataVM = LiveDataVM(apiManager: apiManager, customActionDM: actionDM)
        
        _liveDataVM = StateObject(wrappedValue: liveDataVM)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(liveDataVM)
        }
    }
}

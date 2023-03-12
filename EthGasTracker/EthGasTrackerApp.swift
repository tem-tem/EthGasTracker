//
//  EthGasTrackerApp.swift
//  EthGasTracker
//
//  Created by Tem on 3/9/23.
//

import SwiftUI
import BackgroundTasks

@main
struct EthGasTracker: App {
    @StateObject private var dataController = DataController()
    @StateObject var networkMonitor = NetworkMonitor()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scene
    @AppStorage("test") var test = 1
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkMonitor)
                .environmentObject(dataController)
//            VStack {
//                FetchStatusView()
//                
//                Button("Test") {
//                    BGTaskScheduler.shared.getPendingTaskRequests { all in
//                        print("Pending Tasks Requests", all)
//                    }
//                }
//                Text("\(test)")
//                Button("ADD") {
//                    test = test + 1
//                }
//            }
//                .onChange(of: scene) { newValue in
//                    switch newValue {
//                    case .background:
//                        print("Entered Background")
//                        appDelegate.schedule()
//                    default:
//                        break
//                    }
//                }
        }
    }
}

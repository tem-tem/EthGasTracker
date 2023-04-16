//
//  EthGasTrackerApp.swift
//  EthGasTracker
//
//  Created by Tem on 3/9/23.
//

import SwiftUI
import BackgroundTasks
import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Error requesting notification permissions: \(error)")
            return
        }
        
        if granted {
            print("Notification permissions granted")
        } else {
            print("Notification permissions denied")
        }
    }
}

@main
struct EthGasTracker: App {
    let notificationDelegate = NotificationDelegate()
    @StateObject private var dataController = DataController()
    @StateObject var networkMonitor = NetworkMonitor()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scene
    @AppStorage("test") var test = 1
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkMonitor)
                .environmentObject(dataController)
                .environmentObject(notificationManager)
                .environmentObject(appDelegate)
                .onAppear(perform: requestNotificationPermission)
        }
    }
}

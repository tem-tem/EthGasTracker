//
//  EthGasTrackerApp.swift
//  EthGasTracker
//
//  Created by Tem on 3/9/23.
//

import SwiftUI
import BackgroundTasks
import UserNotifications
import WidgetKit

enum DisplayMode: Int {
    case none = 0
    case dark = 1
    case light = 2
}

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

func checkNotificationPermission(onGranted: @escaping () -> Void, onDenied: @escaping () -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            print("Notification permission granted")
            onGranted()
        case .denied:
            print("Notification permission denied")
            onDenied()
        case .notDetermined:
            print("Notification permission not determined")
            onDenied()
        case .ephemeral:
            print("Notification permission granted temporarily")
            onGranted()
        @unknown default:
            print("Unknown notification permission status")
            onDenied()
        }
    }
}



@main
struct EthGasTracker: App {
    @AppStorage("settings.displayMode") var displayMode: DisplayMode = .none
    @Environment(\.colorScheme) private var defaultColorScheme
    let notificationDelegate = NotificationDelegate()
    @StateObject private var dataController = DataController()
    @StateObject var networkMonitor = NetworkMonitor()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scene
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkMonitor)
                .environmentObject(dataController)
                .environmentObject(notificationManager)
                .environmentObject(appDelegate)
                .onAppear(perform: requestNotificationPermission)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    // Reload all timelines of your widget when the app becomes active.
                    WidgetCenter.shared.reloadAllTimelines()
                }
//                .preferredColorScheme(displayMode == .none ? .none : displayMode == .light ? .light : .dark)
//                .environment(\.colorScheme, displayMode == .system ? UITraitCollection.current.userInterfaceStyle : displayMode == .light ? .light : .dark)
//                .onReceive([self.displayMode].publisher.first()) { _ in
//                    overrideDisplayMode(from: displayMode)
//                }
//                .onChange(of: defaultColorScheme, perform: {_ in
//                    if displayMode == .none {
//                        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = UITraitCollection.current.userInterfaceStyle
//                    }
//                })
//                .preferredColorScheme(colorSchemeSetting == "Light" ? .light : .dark)
        }
    }
}


func overrideDisplayMode(from setting: DisplayMode) {
    var userInterfaceStyle: UIUserInterfaceStyle

    switch setting {
        case .dark: userInterfaceStyle = .dark
        case .light: userInterfaceStyle = .light
        case .none: userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
    }

    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = userInterfaceStyle
}

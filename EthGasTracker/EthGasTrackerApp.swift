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
    @AppStorage(SettingsKeys().colorScheme) var settingsColorScheme: ColorScheme = .none
    let notificationDelegate = NotificationDelegate()
    @StateObject var networkMonitor = NetworkMonitor()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scene
    @StateObject private var notificationManager = NotificationManager()
    @Environment(\.colorScheme) private var defaultColorScheme
    
    var isCurrentAppearanceDark: Bool {
        return (settingsColorScheme == .dark) || (settingsColorScheme == .none && defaultColorScheme == .dark)
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(networkMonitor)
//                .environmentObject(dataController)
                .environmentObject(notificationManager)
                .environmentObject(appDelegate)
                .onAppear(perform: requestNotificationPermission)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    // Reload all timelines of your widget when the app becomes active.
//                    WidgetCenter.shared.reloadAllTimelines()
                }
                .preferredColorScheme(
                    settingsColorScheme == .dark ?
                        .dark :
                        settingsColorScheme == .light ? .light :
                        nil
                )
        }
    }
}

struct PreviewWrapper<Content: View>: View {
    let content: Content
    @ObservedObject var networkMonitor: NetworkMonitor
    @ObservedObject var notificationManager: NotificationManager
    var appDelegate: AppDelegate

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self.networkMonitor = NetworkMonitor()
        self.notificationManager = NotificationManager()
        self.appDelegate = AppDelegate()
    }

    var body: some View {
        content
            .environmentObject(networkMonitor)
            .environmentObject(notificationManager)
            .environmentObject(appDelegate)
    }
}

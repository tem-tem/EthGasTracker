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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("subbed") var subbed: Bool = false
//    let notificationDelegate = NotificationDelegate()
//    @Environment(\.scenePhase) var scene
//    @StateObject private var notificationManager = NotificationManager()
    
    @AppStorage(SettingsKeys().colorScheme) var settingsColorScheme: ColorScheme = .none
    @Environment(\.colorScheme) private var defaultColorScheme
    var isCurrentAppearanceDark: Bool {
        return (settingsColorScheme == .dark) || (settingsColorScheme == .none && defaultColorScheme == .dark)
    }
    
    @StateObject private var activeSelectionVM = ActiveSelectionVM()
    @StateObject private var storeVM = StoreVM()
    @StateObject var networkMonitor = NetworkMonitor()
    
    @StateObject private var customActionDM: CustomActionDataManager
    @StateObject private var liveDataVM: LiveDataVM
    @StateObject private var historicalDataVM: HistoricalDataVM
    @StateObject private var alertVM: AlertVM
    @StateObject private var statsVM: StatsVM
    
    init() {
        let apiManager = APIManager()
        let actionDM = CustomActionDataManager()
        _customActionDM = StateObject(wrappedValue: actionDM)
        _liveDataVM = StateObject(wrappedValue: LiveDataVM(apiManager: apiManager, customActionDM: actionDM))
        _historicalDataVM = StateObject(wrappedValue: HistoricalDataVM(apiManager: apiManager))
        _alertVM = StateObject(wrappedValue: AlertVM(apiManager: apiManager))
        _statsVM = StateObject(wrappedValue: StatsVM(apiManager: apiManager))
    }
    
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appDelegate)
                .environmentObject(liveDataVM)
                .environmentObject(activeSelectionVM)
                .environmentObject(historicalDataVM)
                .environmentObject(storeVM)
                .environmentObject(alertVM)
                .environmentObject(statsVM)
                .environmentObject(customActionDM)
//            MainViewLegacy()
//                .environmentObject(getLatestViewModel)
//                .environmentObject(networkMonitor)
////                .environmentObject(dataController)
//                .environmentObject(notificationManager)
//                .environmentObject(appDelegate)
//                .onAppear(perform: requestNotificationPermission)
//                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//                    // Reload all timelines of your widget when the app becomes active.
////                    WidgetCenter.shared.reloadAllTimelines()
//                }
                .preferredColorScheme(
                    settingsColorScheme == .dark ?
                        .dark :
                        settingsColorScheme == .light ? .light :
                        nil
                )
                .onChange(of: storeVM.checked) { didCheck in
                    if (didCheck) {
                        subbed = !storeVM.purchasedSubscriptions.isEmpty
                        print(storeVM.purchasedSubscriptions)
                    }
                }
        }
    }
}

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

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
import FirebaseAnalytics

let ETH_WIDGET_UNLOCK_URL = "widget://unlock.eth"
let BTC_WIDGET_UNLOCK_URL = "widget://unlock.btc"

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
//    @AppStorage("subbed") var subbed: Bool = false
    
    @AppStorage("subbed", store: UserDefaults(suiteName: "group.TA.EthGas")) var subbed: Bool = PlusFeatureManager.shared.hasPremiumAccess()
//    let notificationDelegate = NotificationDelegate()
//    @Environment(\.scenePhase) var scene
//    @StateObject private var notificationManager = NotificationManager()
    
    @AppStorage(SettingsKeys().colorScheme) var settingsColorScheme: ColorScheme = .none
    @Environment(\.colorScheme) private var defaultColorScheme
    var isCurrentAppearanceDark: Bool {
        return (settingsColorScheme == .dark) || (settingsColorScheme == .none && defaultColorScheme == .dark)
    }
    @StateObject private var alertToastManager = AlertToastManager()
    
    @StateObject private var activeSelectionVM: ActiveSelectionVM
    @StateObject private var storeVM: StoreVM
    @StateObject var networkMonitor: NetworkMonitor
    
    @StateObject private var customActionDM: CustomActionDataManager
    @StateObject private var liveDataVM: LiveDataVM
    @StateObject private var historicalDataVM: HistoricalDataVM
    @StateObject private var alertVM: AlertVM
    @StateObject private var statsVM: StatsVM
    
    @State private var showPurchaseSheet: Bool = false
    
    init() {
        let apiManager = APIManager()
        let actionDM = CustomActionDataManager()
        _customActionDM = StateObject(wrappedValue: actionDM)
        _liveDataVM = StateObject(wrappedValue: LiveDataVM(apiManager: apiManager, customActionDM: actionDM))
        _historicalDataVM = StateObject(wrappedValue: HistoricalDataVM(apiManager: apiManager))
        _alertVM = StateObject(wrappedValue: AlertVM(apiManager: apiManager))
        _statsVM = StateObject(wrappedValue: StatsVM(apiManager: apiManager))
        _activeSelectionVM = StateObject(wrappedValue: ActiveSelectionVM())
        _storeVM = StateObject(wrappedValue: StoreVM())
        _networkMonitor = StateObject(wrappedValue: NetworkMonitor())
        _showPurchaseSheet = State(wrappedValue: false)
        
        
        let secret = ReferralCodeManager.shared.getSecretCode()
        if let userReferralCode = ReferralCodeManager.shared.getReferralCode() {
            let requestBody = ReferralPointsRequest(referralCode: userReferralCode, secret: secret)
            apiManager.getReferralPoints(requestBody: requestBody) { response in
                switch response {
                case .success(let data):
                    UserDefaults.standard.set(data.points, forKey: "points")
                    UserDefaults.standard.set(data.wasReferred, forKey: "wasReferred")
                    UserDefaults.standard.set(data.updatedAt, forKey: "pointsUpdatedAt")
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            apiManager.createUser(secret: secret) { response in
                switch response {
                case .success(let createdUser):
                    ReferralCodeManager.shared.setReferralCode(createdUser.referralCode)
                    let points = createdUser.points
                    UserDefaults.standard.set(points, forKey: "points")
                    UserDefaults.standard.set(false, forKey: "wasReferred")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            MainView(showPurchaseSheet: $showPurchaseSheet)
                .environmentObject(appDelegate)
                .environmentObject(liveDataVM)
                .environmentObject(activeSelectionVM)
                .environmentObject(historicalDataVM)
                .environmentObject(storeVM)
                .environmentObject(alertVM)
                .environmentObject(statsVM)
                .environmentObject(customActionDM)
                .environmentObject(alertToastManager)
                .preferredColorScheme(
                    settingsColorScheme == .dark ?
                        .dark :
                        settingsColorScheme == .light ? .light :
                        nil
                )
                .onChange(of: storeVM.checked) { didCheck in
                    if (didCheck) {
                        if storeVM.purchasedSubscriptions.isEmpty {
                            subbed = PlusFeatureManager.shared.hasPremiumAccess()
                        } else {
                            subbed = true
                        }
                    }
                }
                .onOpenURL { url in
                    if url == URL(string: ETH_WIDGET_UNLOCK_URL) {
                        if (!subbed) {
                            showPurchaseSheet = true
                            let params = [
                                AnalyticsParameterScreenName: "user clicked on widget to unlock subscription",
                            ]
                            Analytics.logEvent("unlock_eth", parameters: params)
                        }
                    }
                    
                    if url == URL(string: BTC_WIDGET_UNLOCK_URL) {
                        if (!subbed) {
                            showPurchaseSheet = true
                            let params = [
                                AnalyticsParameterScreenName: "user clicked on widget to unlock subscription",
                            ]
                            Analytics.logEvent("unlock_btc", parameters: params)
                        }
                    }
                }
        }
    }
}

struct PreviewWrapper<Content: View>: View {
    let content: Content
    
    
    @StateObject private var alertToastManager = AlertToastManager()
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
            .environmentObject(alertToastManager)
    }
}

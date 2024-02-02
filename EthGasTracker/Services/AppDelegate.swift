//
//  AppDelegate.swift
//  EthGasTracker
//
//  Created by Tem on 3/10/23.
//

import SwiftUI
import BackgroundTasks
import FirebaseCore
import FirebaseAnalytics
import AppTrackingTransparency

//class OP: Operation {
//    @AppStorage("test") var test = 1
//    
//    override func main() {
//        print("OPERATION RAN")
//        test = test + 100
//    }
//}

//let FREE_ALERTS_LIMIT = 1

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var deviceToken: String?
//    let dataManager = DataManager()
//    let api_v1 = API_v1()
//    let api_v3 = APIv3()
    
//    @AppStorage("subbed") var subbed: Bool = false
//    @AppStorage("isStale") var isStale = false
//    @AppStorage("currency") var currency: String = "USD"
//    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    
//    @Published var serverMessages: [ServerMessage] = []
//    @Published var currencyRate:Double = 1
//    @Published var timestamp: Int64 = 0
//    @Published var ethPrice = PriceDataEntity(entries: [:])

//    @Published var alerts: [GasAlert] = []
//    @Published var stats: StatsEntries = StatsEntries(statsNormal: [], statsGroupedByHourNormal: [], statsFast: [], statsGroupedByHourFast: [], timestamp: Date(timeIntervalSince1970: 0), avgMin: 0, avgMax: 1)
    
//    @Published var gas: [String: NormalFast] = [:]
//    @Published var actions: ActionEntityGroups = []
//    @Published var defaultActions: ActionEntityGroups = []
//    @Published var currentStats: CurrentStats = CurrentStats.placeholder()
//    @Published var gasLevel: GasLevel = GasLevel(currentStats: CurrentStats.placeholder(), currentGas: 0.0)
//    @Published var gasIndexEntries: [GasIndexEntity.ListEntry] = []
//    @Published var gasIndexEntriesMinMax: (min:Double?, max:Double?) = (min: nil, max: nil)
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//        self.fetchAlerts()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
//            self.fetchAlerts()
        }
//        self.fetchMessages()
        
        
        FirebaseApp.configure()
        
        if NSClassFromString("ATTrackingManager") != nil {
            ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        Analytics.logEvent("tracking_authorized", parameters: nil)
                    case .denied:
                        Analytics.logEvent("tracking_denied", parameters: nil)
                    default:
                        break
                }
            }
        }
        Analytics.logEvent("pickup", parameters: nil)
        return true
    }
    
//    func applicationWillTerminate(_ application: UIApplication) {
//        repeatedFetch.stop()
//    }
}

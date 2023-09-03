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

class OP: Operation {
    @AppStorage("test") var test = 1
    
    override func main() {
        print("OPERATION RAN")
        test = test + 100
    }
}
let one_minute = 6
var AMOUNT_TO_FETCH = one_minute * 15
var FETCH_INTERVAL = 10.0

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
//    @AppStorage(UIKeys.dataState) private var dataState: DataState = .loading
    @AppStorage("isStale") var isStale = false
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @Published var deviceToken: String?
    let dataManager = DataManager()
    let api_v1 = API_v1()
    
    // data received from gas-server
    @Published var timestamp: Int64 = 0
    @Published var ethPrice = PriceDataEntity(entries: [:])
    @Published var legacyGas: LegacyGasData = LegacyGasData(low: 0, avg: 0, high: 0)
    @Published var actions: [Dictionary<String, [ActionEntity]>.Element] = []
    
    @Published var gas = GasIndexEntity(entries: [:])
    @Published var gasIndexEntries: [GasIndexEntity.ListEntry] = []
    @Published var gasIndexEntriesMinMax: (min: Float?, max: Float?) = (min: nil, max: nil)
    
    // data received from alerts-server
    @Published var alerts: [GasAlert] = []
    
    @Published var stats: StatsEntries = StatsEntries(statsNormal: [], statsGroupedByHourNormal: [], statsFast: [], statsGroupedByHourFast: [], timestamp: Date(timeIntervalSince1970: 0), avgMin: 0, avgMax: 1)
    
    @Published var serverMessages: [ServerMessage] = []
    
    var repeatedFetch: RepeatingTask {
        RepeatingTask(interval: FETCH_INTERVAL) {
            self.dataManager.getEntities(amount: AMOUNT_TO_FETCH) { result in
                switch result {
                case .success(let entities):
                    DispatchQueue.main.async {
                        self.ethPrice = entities.ethPriceEntity
                        self.timestamp = Int64(entities.ethPriceEntity.lastEntry()?.key ?? "0") ?? 0
                        self.isStale = false
                        
                        self.legacyGas = LegacyGasData(
                            low: entities.legacyGasIndexEntity.entries.first?.value.low ?? 5.0,
                            avg: entities.legacyGasIndexEntity.entries.first?.value.avg ?? 0.0,
                            high: entities.legacyGasIndexEntity.entries.first?.value.high ?? 0.0
                        )
                        
                        self.actions = entities.actionEntities.sorted(by: {$0.key < $1.key})
                        
                        self.gas = entities.gasIndexEntity
                        self.gasIndexEntries = entities.gasIndexEntity.getEntriesList()
                        let minEntry = entities.gasIndexEntity.findMin(in: self.gasIndexEntries, by: self.isFastMain ? \.fast : \.normal)
                        let maxEntry = entities.gasIndexEntity.findMax(in: self.gasIndexEntries, by: self.isFastMain ? \.fast : \.normal)
                        let min = self.isFastMain ? minEntry?.fast : minEntry?.normal
                        let max = self.isFastMain ? maxEntry?.fast : maxEntry?.normal
                        self.gasIndexEntriesMinMax = (
                            min: (min ?? 0) * 0.97,
                            max: (max ?? 10) * 1.03
                        )
                    }
                case .failure(let error):
                    print("Error normalizing response: \(error)")
                }
            }
        }
    }
    
    func fetchMessages() {
        self.api_v1.fetchServerMessages() { result in
            switch result {
            case .success(let msgs):
                DispatchQueue.main.async {
                    self.serverMessages = msgs
                }
            case .failure(let error):
                print("error while fetching server messages")
                print(error)
            }
        }
    }
    
    func fetchAlerts () {
        guard let deviceId = self.deviceToken else {
            return
        }
        self.api_v1.getAlerts(by: deviceId) { result in
            switch result {
            case .success(let alertsFromResponse):
                DispatchQueue.main.async {
                    self.alerts = alertsFromResponse
                }
            case .failure(let error):
                print("error while fetching alerts")
                print(error)
            }
        }
    }
    
    func toggleAlert(by alertId: String) {
        self.api_v1.toggleAlert(by: alertId) { result in
            guard let index = self.alerts.firstIndex(where: { $0.id == alertId }) else {
                print("Alert with ID \(alertId) not found")
                return
            }
            
            let fallbackAlerts = self.alerts
            DispatchQueue.main.async {
                self.alerts[index].disabled = !(self.alerts[index].disabled ?? false)
            }
            
            switch result {
            case .success():
                return
            case .failure(let error):
                print("error while toggling \(alertId)")
                print(error)
                
                DispatchQueue.main.async {
                    self.alerts = fallbackAlerts
                }
            }
        }
    }
    
    func deleteAlert(by alertId: String) {
        self.api_v1.deleteAlert(by: alertId) { result in
            let fallbackAlerts = self.alerts
            DispatchQueue.main.async {
                self.alerts.removeAll(where: { $0.id == alertId })
            }
            
            switch result {
            case .success():
                return
            case .failure(let error):
                print("error while deleting \(alertId)")
                print(error)
                
                DispatchQueue.main.async {
                    self.alerts = fallbackAlerts
                }
            }
        }
    }
    
    func addAlert(alert: GasAlert) {
        self.api_v1.addAlert(alert) { result in
            
            switch result {
            case .success(let newAlertId):
                DispatchQueue.main.async {
                    self.alerts.append(
                        GasAlert(
                            id: newAlertId,
                            deviceId: alert.deviceId,
                            mutePeriod: alert.mutePeriod,
                            conditions: alert.conditions,
                            confirmationPeriod: alert.confirmationPeriod,
                            legacyGas: alert.legacyGas
                        ))
                }
                return
            case .failure(let error):
                print("error while adding new alert")
                print(error)
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.fetchAlerts()
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
            self.fetchAlerts()
        }
        self.fetchMessages()
        repeatedFetch.start()
        self.dataManager.getStatEntries() { result in
            switch result {
            case .success(let statEntries):
                DispatchQueue.main.async {
                    self.stats = statEntries
                }
            case .failure(let error):
                print("Error while getting stats through dataManager from appDelegate: \(error)")
            }
        }
        
        
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
    
    func applicationWillTerminate(_ application: UIApplication) {
        repeatedFetch.stop()
    }
}

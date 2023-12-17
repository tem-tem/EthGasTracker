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

let FREE_ALERTS_LIMIT = 1

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    let dataManager = DataManager()
    let api_v1 = API_v1()
//    @AppStorage(UIKeys.dataState) private var dataState: DataState = .loading
    @AppStorage("subbed") var subbed: Bool = false
    @AppStorage("isStale") var isStale = false
    @AppStorage("currency") var currency: String = "USD"
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @Published var deviceToken: String?
    
    @Published var currencyRate: Float = 1
    
    // data received from gas-server
    @Published var timestamp: Int64 = 0
    @Published var ethPrice = PriceDataEntity(entries: [:])
    @Published var legacyGas: LegacyGasData = LegacyGasData(low: 0, avg: 0, high: 0)
    @Published var allActions: [Dictionary<String, [ActionEntity]>.Element] = []
    
    // data received from alerts-server
    @Published var alerts: [GasAlert] = []
    
    @Published var stats: StatsEntries = StatsEntries(statsNormal: [], statsGroupedByHourNormal: [], statsFast: [], statsGroupedByHourFast: [], timestamp: Date(timeIntervalSince1970: 0), avgMin: 0, avgMax: 1)
    
    @Published var serverMessages: [ServerMessage] = []
    
//    SWITCHING TO V2
    let api_v3 = APIv3()
    @Published var gas: [String: NormalFast] = [:]
    @Published var actions: GroupedActions = []
    @Published var defaultActions: GroupedActions = []
    @Published var currentStats: CurrentStats = CurrentStats.placeholder()
    @Published var gasLevel: GasLevel = GasLevel(currentStats: CurrentStats.placeholder(), currentGas: 0.0)
    @Published var gasIndexEntries: [GasIndexEntity.ListEntry] = []
    @Published var gasIndexEntriesMinMax: (min: Float?, max: Float?) = (min: nil, max: nil)
    
    @Published var historicalData_1h: HistoricalDataCahced = HistoricalDataCahced.placeholder()
    @Published var historicalData_1d: HistoricalDataCahced = HistoricalDataCahced.placeholder()
    @Published var historicalData_1w: HistoricalDataCahced = HistoricalDataCahced.placeholder()
    @Published var historicalData_1m: HistoricalDataCahced = HistoricalDataCahced.placeholder()
    
    var repeatedFetch: RepeatingTask {
        RepeatingTask(interval: FETCH_INTERVAL) {
            self.refresh()
        }
    }
    
    func refresh() -> Void {
        let carryingCurrency = self.currency
        self.api_v3.getLatest(currency: carryingCurrency) { result in
            switch result {
            case .success(let latestValues):
                DispatchQueue.main.async {
                    if (!self.subbed && self.alerts.count > 0) {
                        self.cleanUpAlerts()
                    }
                    self.currentStats = latestValues.currentStats
                    self.gas = latestValues.indexes.normalizedGas
                    self.gasIndexEntries = latestValues.indexes.getEntriesList()
                    
                    self.gasLevel = GasLevel(currentStats: latestValues.currentStats, currentGas: self.gasIndexEntries.last?.normal ?? 0.0)
                    
                    if self.currency != "USD", let rateString = latestValues.currencyRate, let rate = Float(rateString) {
                        self.currencyRate = rate
                        self.ethPrice = latestValues.indexes.getNormalizedEthPrice(in: rate)
                    } else {
                        self.ethPrice = latestValues.indexes.normalizedEthPrice
                    }
                    
                    let minMaxValues = latestValues.indexes.findMinMax()
                    let min = self.isFastMain ? minMaxValues.fastMin : minMaxValues.normalMin
                    let max = self.isFastMain ? minMaxValues.fastMax : minMaxValues.normalMax
                    self.gasIndexEntriesMinMax = (min: (min ?? 0.0) * 0.97, max: (max ?? 0.0) * 1.03)
                    
                    self.actions = normalizeAndGroupActions(from: latestValues)
                    self.defaultActions = normalizeAndGroupActions(from: latestValues, defaultOnly: true)
                    
                    if let lastTimestamp = self.gasIndexEntries.last?.key {
                        self.timestamp = Int64((Double(lastTimestamp ?? "1") ?? 1) / 1000)
                    }
//                        Date().timeIntervalBetween1970AndReferenceDate(self.gasIndexEntries.first?.timestamp)
                }
            case .failure(let error):
                print("Error in api v2 get latest response: \(error)")
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

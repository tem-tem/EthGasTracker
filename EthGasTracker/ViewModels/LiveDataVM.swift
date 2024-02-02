//
//  GetLatestViewModel.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation
import SwiftUI

let one_minute = 6
var AMOUNT_TO_FETCH = one_minute * 15
var FETCH_INTERVAL = 12.0

class DataFetcherVM: ObservableObject {
    let apiManager: APIManager
    
    @AppStorage("currency") var currency: String = "USD"
    @AppStorage("subbed") var subbed: Bool = false
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    @Published var fetchInterval: Double = FETCH_INTERVAL
    
    @Published var timestamp: Int64 = 0
    
    @Published var serverMessages: [ServerMessage] = []
    
    @Published var currencyRate: Float = 1
    
    @Published var ethPrice = PriceDataEntity(entries: [:])

    @Published var alerts: [GasAlert] = []
    
    @Published var stats: StatsEntries = StatsEntries(statsNormal: [], statsGroupedByHourNormal: [], statsFast: [], statsGroupedByHourFast: [], timestamp: Date(timeIntervalSince1970: 0), avgMin: 0, avgMax: 1)
    
    @Published var actions: GroupedActions = []
    @Published var defaultActions: GroupedActions = []
    
    @Published var currentStats: CurrentStats = CurrentStats.placeholder()
    
    @Published var gas: [String: NormalFast] = [:]
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
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
        self.repeatedFetch.start()
    }
    
    func refresh() -> Void {
        let carryingCurrency = self.currency
        apiManager.getLatestData(currency: carryingCurrency) { result in
            switch result {
            case .success(let latestValues):
                DispatchQueue.main.async {
//                    if (!self.subbed && self.alerts.count > 0) {
//                        self.cleanUpAlerts()
//                    }
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
                        self.timestamp = Int64((Double(lastTimestamp) ?? 1) / 1000)
                    }
//                        Date().timeIntervalBetween1970AndReferenceDate(self.gasIndexEntries.first?.timestamp)
                }
            case .failure(let error):
                print("Error in GetLatestViewModel response: \(error)")
            }
        }
    }
}

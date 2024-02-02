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

enum Status: Int {
    case offline = 0
    case fetching = 1
    case ok = 2
    case stale = 3
    case error = 4
}

class LiveDataVM: ObservableObject {
    let apiManager: APIManager
    
    @Published var status: Status = .fetching
    
    @AppStorage("currency", store: UserDefaults(suiteName: "group.TA.EthGas")) var currency: String = "USD"
    @AppStorage("currencyRate") var currencyRate = 1.0
    @AppStorage("subbed") var subbed: Bool = false
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    @Published var fetchInterval: Double = FETCH_INTERVAL
    
    @Published var timestamp: Double = 0
    @Published var currentStats: CurrentStats = CurrentStats.placeholder()
    @Published var ethPriceEntity = PriceDataEntity(from: [], with: [])
    @Published var gasDataEntity: GasDataEntity = GasDataEntity(from: [], with: [])
    @Published var gasLevel: GasLevel = GasLevel(currentStats: CurrentStats.placeholder(), currentGas: 0.0)

    @Published var actions: [ActionEntity] = []
    
    var repeatedFetch: RepeatingTask {
        return RepeatingTask(interval: FETCH_INTERVAL) {
            self.refresh()
        }
    }
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
        self.repeatedFetch.start()
    }
    
    func refresh() -> Void {
        let carryingCurrency = self.currency
        self.status = .fetching
        apiManager.getLiveData(currency: carryingCurrency) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.currentStats = data.currentStats
                    self.ethPriceEntity = PriceDataEntity(
                        from: data.indexes.eth_price,
                        with: data.indexes.commonTimestamps,
                        in: data.currencyRate
                    )
                    self.gasDataEntity = GasDataEntity(
                        from: data.indexes.gas,
                        with: data.indexes.commonTimestamps
                    )
                    
                    self.gasLevel = GasLevel(currentStats: data.currentStats, currentGas: self.gasDataEntity.lastNormal)
                    
                    self.actions = data.actions.values
                        .sorted { $0.key < $1.key }
                        .map {
                        let isPinned = data.defaultActions.keys.contains($0.key)
                        return ActionEntity(
                            rawAction: $0,
                            gasEntries: self.gasDataEntity.entries,
                            priceEntries: self.ethPriceEntity.entries,
                            isPinned: isPinned
                        )
                    }
                    
                    self.timestamp = self.gasDataEntity.entries.last?.timestamp ?? 0
                    
                    self.status = .ok
                }
            case .failure(let error):
                self.status = .error
                print("Error in GetLatestViewModel response: \(error)")
            }
        }
    }
}

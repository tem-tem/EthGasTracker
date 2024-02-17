//
//  WatchLiveDataVM.swift
//  EthGasTrackerWatch Watch App
//
//  Created by Tem on 2/16/24.
//

import Foundation

class WatchLiveDataVM: ObservableObject {
    let apiManager: APIManager
    
    @Published var ethPrice: Double = 0
    @Published var gasPrice: Double = 0
    @Published var gasLevel: GasLevel = GasLevel(currentStats: CurrentStats.placeholder(), currentGas: 0)
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    func fetchData() -> Void {
        let currency = UserDefaults(suiteName: "group.TA.EthGas")?.string(forKey: "currency") ?? "USD"
        apiManager.getLiveData(currency: currency) { result in
            switch result {
            case .success(let data):
                let ethPriceEntity = PriceDataEntity(
                    from: data.indexes.eth_price,
                    with: data.indexes.commonTimestamps,
                    in: data.currencyRate
                )
                let gasDataEntity = GasDataEntity(
                    from: data.indexes.gas,
                    with: data.indexes.commonTimestamps
                )
                let gasLevel = GasLevel(currentStats: data.currentStats, currentGas: gasDataEntity.lastNormal)
                
                self.ethPrice = ethPriceEntity.entries.last?.price ?? 0
                self.gasPrice = gasLevel.currentGas
                self.gasLevel = gasLevel
            case .failure(let error):
                print("Error in GetLatestViewModel response: \(error)")
            }
        }
    }

}

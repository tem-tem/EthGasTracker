//
//  SharedDataRepository.swift
//  EthGasWidgetExtension
//
//  Created by Tem on 2/1/24.
//

import Foundation

class SharedDataRepository {
    static let shared = SharedDataRepository()
    private let actionDataManager = CustomActionDataManager()

    private var lastFetchedData: (data: GasIndexEntry?, timestamp: Date?)
    private let apiManager = APIManager()
    private let dataValidityDuration: TimeInterval = 300 // Data is considered fresh for 5 minutes
    private let fetchQueue = DispatchQueue(label: "TEMTEM.EthGasTracker.EthGasWidget.SharedDataRepository.fetchQueue")
    
    private init() {}
    
    func fetchDataIfNeeded(completion: @escaping (Result<GasIndexEntry, Error>) -> Void) {
        fetchQueue.async { [self] in
            let currentTime = Date()
            print("FETCHING FROM WIDGET current time: \(currentTime)")
            print("last fetched time: \(lastFetchedData.timestamp ?? Date.distantPast)")
            if currentTime.timeIntervalSince(lastFetchedData.timestamp ?? Date.distantPast) < dataValidityDuration {
                if let data = lastFetchedData.data {
                    print("GOING WITH CACHED DATA")
                    completion(.success(data))
                    return
                }
            }
            
            print("FETCHING NEW DATA")
            
            fetchData(completion: completion)
        }
    }
    
    private func fetchData(completion: @escaping (Result<GasIndexEntry, Error>) -> Void) {
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
                
                let entry = GasIndexEntry(
                    date: Date(),
                    gas: gasLevel.currentGas,
                    ethPrice: ethPriceEntity.entries.last?.price ?? 0,
                    gasDataEntity: gasDataEntity,
                    gasLevel: gasLevel,
                    actions: self.actionDataManager.pinnedActions
                )
                completion(.success(entry))
//                let timeline = Timeline(entries: [entry], policy: .atEnd)
            case .failure(let error):
//                self.status = .error
                print("Error in GetLatestViewModel response: \(error)")
                completion(.failure(error))
            }
        }
    }
}

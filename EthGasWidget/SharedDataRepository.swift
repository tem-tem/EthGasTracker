//
//  SharedDataRepository.swift
//  EthGasWidgetExtension
//
//  Created by Tem on 2/1/24.
//

import Foundation

class SharedDataRepository {
    static let shared = SharedDataRepository()
    
    private var lastFetchedData: (data: GasIndexEntry?, timestamp: Date?)
    private let apiManager = APIManager()
    private let dataValidityDuration: TimeInterval = 300 // Data is considered fresh for 5 minutes
    
    private init() {}
    
    func fetchDataIfNeeded(completion: @escaping (Result<GasIndexEntry, Error>) -> Void) {
        print("FETCHING FROM WIDGET")
        let currentTime = Date()
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
                let actions: [ActionEntity] = data.actions.values
                    .sorted { $0.key < $1.key }
                    .map {
                    let isPinned = data.defaultActions.keys.contains($0.key)
                    return ActionEntity(
                        rawAction: $0,
                        gasEntries: gasDataEntity.entries,
                        priceEntries: ethPriceEntity.entries,
                        isPinned: isPinned
                    )
                }
                
                let entry = GasIndexEntry(date: Date(), gasDataEntity: gasDataEntity, gasLevel: gasLevel, actions: actions)
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

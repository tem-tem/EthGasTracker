//
//  DataManager.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import Foundation
import CoreData


class DataManager: ObservableObject {
    let api_v1: API_v1
    let coreDataHandler: CoreDataHandler
    
//    @Published var entities = Entities(priceEntities: [], gasEntities: [], legacyGasEntities: [], transferPriceEntities: [])

    init() {
        self.api_v1 = API_v1()
        self.coreDataHandler = CoreDataHandler()
    }

    func deleteDataOlderThan2Years() {
        let oneMonthAgo = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        let thresholdTimestamp = Int64(oneMonthAgo.timeIntervalSince1970)

        coreDataHandler.deleteDataOlderThanTimestamp(thresholdTimestamp)
    }
    
    func fetchAndStoreData(amount: Int, completion: @escaping (Result<Entities, Error>) -> Void) {
        api_v1.fetchLatestData(amount: amount) { result in
            switch result {
            case .success(let data):
                let coreDataEntities = self.coreDataHandler.generateEntities(data: data, shouldSave: false)
//                self.entities = coreDataEntities

                completion(.success(coreDataEntities))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func readData(entityName: String, amount: Int) -> [NSManagedObject]? {
        return coreDataHandler.readData(entityName: entityName, amount: amount)
    }

    func pruneAllData() {
        coreDataHandler.pruneAllData()
    }
}

//
//  DataController.swift
//  EthGasTracker
//
//  Created by Tem on 3/9/23.
//

//import CoreData
//import Foundation
//import SwiftUI
//import Combine
//
//class DataController: ObservableObject {
//    let container = NSPersistentContainer(name: "Gas")
//    
////    @Published var price: Price?
////    @Published var prices: [Price] = []
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        container.loadPersistentStores { description, error in
//            if let error = error {
//                fatalError("Unable to load persistent stores: \(error)")
//            }
//        }
//        
//        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
//            .sink { [weak self] _ in
//                self?.fetchAll()
//            }
//            .store(in: &cancellables)
//        
//        fetchAll()
//    }
//    
//    func addGasPrice(low: String, avg: String, high: String) {
//        let request = Price.fetchRequest()
//        let count = try? container.viewContext.count(for: request)
//        
//        if let count = count, count >= 100 {
//            let fetchRequest: NSFetchRequest<Price> = Price.fetchRequest()
//            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastUpdate", ascending: true)]
//            fetchRequest.fetchLimit = count - 99
//            
//            let stalePrices = try? container.viewContext.fetch(fetchRequest)
//            
//            for price in stalePrices ?? [] {
//                container.viewContext.delete(price)
//            }
//        }
//        
//        let price = Price(context: container.viewContext)
//        price.avg = avg
//        price.high = high
//        price.low = low
//        price.lastUpdate = Date()
//        saveData()
//    }
//
//    private func fetchAll() {
//        let priceRequest = Price.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "lastUpdate", ascending: false)
//        priceRequest.sortDescriptors = [sortDescriptor]
//        
//        if let fetchedPrices = try? container.viewContext.fetch(priceRequest) {
//            prices = fetchedPrices
//        }
//    }
//    
//    func saveData() {
//        try? container.viewContext.save()
//        fetchAll()
//    }
//}

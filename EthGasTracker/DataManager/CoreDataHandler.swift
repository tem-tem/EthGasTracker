//
//  CoreDataHandler.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import Foundation
import CoreData

struct Entities {
    var priceEntities: [PriceEntity]
    var gasEntities: [GasEntity]
    var legacyGasEntities: [LegacyGasEntity]
    var transferPriceEntities: [TransferPriceEntity]
}

// TODO: this is deprecated for now
class CoreDataHandler {
    private let persistentContainer: NSPersistentContainer

    init() {
        self.persistentContainer = NSPersistentContainer(name: "Gas")
        self.persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    func entityExists<T: NSManagedObject>(forTimestamp timestamp: Int64, ofType type: T.Type, inContext context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: type))
        fetchRequest.predicate = NSPredicate(format: "timestamp == %ld", timestamp)
        let existingRecords = try? context.fetch(fetchRequest)
        return existingRecords?.isEmpty == false
    }
    
//    TODO: handle data existance check properly
//    TODO: handle long list fetch properly
//    TODO: handle saving properly
//    TODO: handle big data fetch more properly
//    TODO: maybe void going through coredata handler

    func generateEntities(data: [String: Any], shouldSave: Bool) -> Entities {
        let context = persistentContainer.viewContext
        var entities = Entities(priceEntities: [], gasEntities: [], legacyGasEntities: [], transferPriceEntities: [])

        // Ethereum Price
        if let ethData = data["eth_price"] as? [String: [String: String]] {
            for (timestampString, priceInfo) in ethData {
                if let timestamp = Int64(timestampString),
//                   !entityExists(forTimestamp: timestamp, ofType: PriceEntity.self, inContext: context),
                   let price = priceInfo["price"] {
                    
                    let priceEntity = PriceEntity(context: context)
                    priceEntity.timestamp = timestamp
                    priceEntity.price = Float(price) ?? 0.0
                    
                    entities.priceEntities.append(priceEntity)
                }
            }
        }
        
        // Gas Price
        if let gasDataList = data["gas"] as? [String: [String: String]] {
            for (timestampString, gasData) in gasDataList {
                
                if let timestamp = Int64(timestampString),
//                   !entityExists(forTimestamp: timestamp, ofType: GasEntity.self, inContext: context),
                    let normal = gasData["normal"],
                    let fast = gasData["fast"] {
                    
                    let gasEntity = GasEntity(context: context)
                    gasEntity.timestamp = timestamp
                    gasEntity.fast = Float(fast) ?? 0.0
                    gasEntity.normal = Float(normal) ?? 0.0
                    
                    entities.gasEntities.append(gasEntity)
                }
            }
        }
        
        // Legacy Gas (from etherscan)
        if let legacyGasDataList = data["etherscan_gas_oracle"] as? [String: [String: String]] {
            for (timestampString, legacyGasData) in legacyGasDataList {
                if let timestamp = Int64(timestampString),
//                   !entityExists(forTimestamp: timestamp, ofType: LegacyGasEntity.self, inContext: context),
                    let avg = legacyGasData["avg"],
                    let high = legacyGasData["high"],
                    let low = legacyGasData["low"] {
                    
                    let legacyGasEntity = LegacyGasEntity(context: context)
                    legacyGasEntity.timestamp = timestamp
                    legacyGasEntity.avg = Float(avg) ?? 0.0
                    legacyGasEntity.high = Float(high) ?? 0.0
                    legacyGasEntity.low = Float(low) ?? 0.0
                    
                    entities.legacyGasEntities.append(legacyGasEntity)
                }
            }
        }

//        // Handling TransferPriceEntity for various fields
//        for (name, transferData) in data {
//            if name.starts(with: "transferPrice_") {
//                if let priceData = transferData as? [String: [String: String]] {
//                    for (timestampString, priceInfo) in priceData {
//                        if let timestamp = Int64(timestampString),
////                           !entityExists(forTimestamp: timestamp, ofType: TransferPriceEntity.self, inContext: context),
//                            let fast = priceInfo["fast"],
//                            let normal = priceInfo["normal"] {
//                            
//                            let transferPriceEntity = TransferPriceEntity(context: context)
//                            transferPriceEntity.timestamp = timestamp
//                            transferPriceEntity.action = name.replacingOccurrences(of: "transferPrice_", with: "")
//                            transferPriceEntity.fast = Float(fast) ?? 0.0
//                            transferPriceEntity.normal = Float(normal) ?? 0.0
//                            entities.transferPriceEntities.append(transferPriceEntity)
//                        }
//                    }
//                }
//            }
//        }

        if (shouldSave) {
            saveContext()
        }
        
        return entities
    }
    
    func readData(entityName: String, amount: Int) -> [NSManagedObject]? {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        // Fetch the latest records by sorting by an appropriate attribute such as timestamp
        // Make sure the entity has an attribute that allows sorting in chronological order
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Limit the number of fetched results to the specified amount
        fetchRequest.fetchLimit = amount
        
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    
    func deleteDataOlderThanTimestamp(_ thresholdTimestamp: Int64) {
        let context = persistentContainer.viewContext

        deleteDataOlderThan(timestamp: thresholdTimestamp, ofType: PriceEntity.self, inContext: context)
        deleteDataOlderThan(timestamp: thresholdTimestamp, ofType: GasEntity.self, inContext: context)
        deleteDataOlderThan(timestamp: thresholdTimestamp, ofType: TransferPriceEntity.self, inContext: context)
        deleteDataOlderThan(timestamp: thresholdTimestamp, ofType: LegacyGasEntity.self, inContext: context) // If needed

        saveContext() // Don't forget to save after making changes!
    }
    
    func deleteDataOlderThan<T: NSManagedObject>(timestamp: Int64, ofType type: T.Type, inContext context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: type))
        fetchRequest.predicate = NSPredicate(format: "timestamp < %ld", timestamp)

        do {
            let oldRecords = try context.fetch(fetchRequest)
            for record in oldRecords {
                context.delete(record)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func pruneAllData() {
        let context = persistentContainer.viewContext
        let coordinator = persistentContainer.persistentStoreCoordinator
        
        let entities = persistentContainer.managedObjectModel.entities
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name ?? "")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try coordinator.execute(deleteRequest, with: context)
            } catch let error as NSError {
                print("Error deleting entity data. \(error), \(error.userInfo)")
            }
        }
        
        // Save changes
        saveContext()
    }


}

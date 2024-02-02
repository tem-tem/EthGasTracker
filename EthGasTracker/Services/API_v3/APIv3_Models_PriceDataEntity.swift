//
//  APIv3_Models_EthPriceEntity.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

struct PriceData {
    var price: Float
}

struct PriceDataEntity {
    let entries: [String: PriceData]
    let metadata: Metadata
    
    init(entries: [String: PriceData]) {
        self.entries = entries
        self.metadata = Metadata(name: "ETH", groupName: "Indexes", key: "eth_price", limit: 0)
    }
    
    func lastEntry() -> (key: String, value: PriceData)? {
        guard let lastTimestampKey = entries.keys.map({ Int($0) ?? 0 }).max(), let lastTimestamp = entries[String(lastTimestampKey)] else {
            return nil
        }
        return (String(lastTimestampKey), lastTimestamp)
    }
    
    func getEntriesDict() -> [(key: String, value: PriceData)] {
        return entries.map { (key: $0.key, value: $0.value) }
            .sorted { (lhs, rhs) in
                // Convert keys to integers and compare
                if let lhsKey = Int(lhs.key), let rhsKey = Int(rhs.key) {
                    return lhsKey < rhsKey
                }
                return false
            }
    }
    
    func minMaxEntries() -> (min: Float, max: Float)? {
        guard let firstEntry = entries.first?.value else {
            return nil
        }

        var min = firstEntry.price
        var max = firstEntry.price

        for entry in entries.values {
            if entry.price < min {
                min = entry.price
            }
            if entry.price > max {
                max = entry.price
            }
        }

        return (min, max)
    }
}

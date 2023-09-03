//
//  ActionEntity.swift
//  EthGasTracker
//
//  Created by Tem on 8/9/23.
//

import Foundation

struct Metadata {
    let name: String
    let groupName: String
    let key: String
    let limit: Int64
}

struct NormalFast {
    var normal: Float
    var fast: Float
}

struct ActionEntity {
    let entries: [String: NormalFast]
    let metadata: Metadata
    
    func lastEntry() -> (key: String, value: NormalFast)? {
        guard let lastTimestampKey = entries.keys.map({ Int($0) ?? 0 }).max(), let lastTimestamp = entries[String(lastTimestampKey)] else {
            return nil
        }
        return (String(lastTimestampKey), lastTimestamp)
    }
    
    func getEntriesDict() -> [(key: String, value: NormalFast)] {
        return entries.map { (key: $0.key, value: $0.value) }
            .sorted { (lhs, rhs) in
                // Convert keys to integers and compare
                if let lhsKey = Int(lhs.key), let rhsKey = Int(rhs.key) {
                    return lhsKey < rhsKey
                }
                return false
            }
    }
    
    func minMaxEntries(forFast speedTypeIsFast: Bool) -> (min: Float, max: Float)? {
        guard let firstEntry = entries.first?.value else {
            return nil
        }

        var min: Float
        var max: Float

        if speedTypeIsFast {
            min = firstEntry.fast
            max = firstEntry.fast
            for entry in entries.values {
                if entry.fast < min {
                    min = entry.fast
                }
                if entry.fast > max {
                    max = entry.fast
                }
            }
        } else {
            min = firstEntry.normal
            max = firstEntry.normal
            for entry in entries.values {
                if entry.normal < min {
                    min = entry.normal
                }
                if entry.normal > max {
                    max = entry.normal
                }
            }
        }

        return (min, max)
    }
}


struct GasIndexEntity {
    let entries: [String: NormalFast]
    let metadata: Metadata
    
    init(entries: [String: NormalFast]) {
        self.entries = entries
        self.metadata = Metadata(name: "Gas", groupName: "Indexes", key: "gas", limit: 0)
    }
    
    func lastEntry() -> (key: String, value: NormalFast)? {
        guard let lastTimestampKey = entries.keys.map({ Int($0) ?? 0 }).max(), let lastTimestamp = entries[String(lastTimestampKey)] else {
            return nil
        }
        return (String(lastTimestampKey), lastTimestamp)
    }
    
    func getEntriesDict() -> [(key: String, value: NormalFast)] {
        return entries.map { (key: $0.key, value: $0.value) }
            .sorted { (lhs, rhs) in
                // Convert keys to integers and compare
                if let lhsKey = Int(lhs.key), let rhsKey = Int(rhs.key) {
                    return lhsKey < rhsKey
                }
                return false
            }
    }
    
    typealias ListEntry = (index: Int, timestamp: Date, normal: Float, fast: Float, key: String)
    
    func getEntriesList() -> [ListEntry] {
        return entries.map { entry in
            if let timestamp = Double(entry.key) {
                let date = Date(timeIntervalSince1970: timestamp)
                return (timestamp: date, normal: entry.value.normal, fast: entry.value.fast, key: entry.key)
            }
            return nil
        }
        .compactMap { $0 }
        .sorted { (lhs, rhs) in
            return lhs.timestamp < rhs.timestamp
        }
        .enumerated()
        .map { (index, element) in
            return (index: index, timestamp: element.timestamp, normal: element.normal, fast: element.fast, key: element.key)
        }
    }
    
    func findMin<T: Comparable>(in entriesList: [ListEntry], by keyPath: KeyPath<ListEntry, T>) -> ListEntry? {
        return entriesList.min(by: { lhs, rhs in
            lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
        })
    }

    func findMax<T: Comparable>(in entriesList: [ListEntry], by keyPath: KeyPath<ListEntry, T>) -> ListEntry? {
        return entriesList.max(by: { lhs, rhs in
            lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
        })
    }
}



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

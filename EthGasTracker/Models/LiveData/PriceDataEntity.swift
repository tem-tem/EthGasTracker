//
//  PriceData.swift
//  EthGasTracker
//
//  Created by Tem on 1/9/24.
//

import Foundation

struct PriceDataEntity {
    typealias Entry = (price: Double, timestamp: Double, key: String, date: Date)
    
    let entries: [Entry]
    let metadata: Metadata
    let min: Double
    let max: Double
    
    init(from rawData: [ResponseIndex], with timestamps: Set<String>, in currencyRate: String? = "1") {
        self.entries = PriceDataEntity.buildEntries(from: rawData, with: timestamps, in: currencyRate)
        self.metadata = Metadata(name: "ETH", groupName: "Indexes", key: "eth_price", limit: 0, pinned: false)
        self.min = entries.map { $0.price }.min() ?? 0
        self.max = entries.map { $0.price }.max() ?? 0
    }
    
//    func lastEntry() -> (key: String, value: PriceData)? {
//        guard let lastTimestampKey = entries.keys.map({ Int($0) ?? 0 }).max(), let lastTimestamp = entries[String(lastTimestampKey)] else {
//            return nil
//        }
//        return (String(lastTimestampKey), lastTimestamp)
//    }
    
//    func getEntriesDict() -> [(key: String, value: PriceData)] {
//        return entries.map { (key: $0.key, value: $0.value) }
//            .sorted { (lhs, rhs) in
//                // Convert keys to integers and compare
//                if let lhsKey = Int(lhs.key), let rhsKey = Int(rhs.key) {
//                    return lhsKey < rhsKey
//                }
//                return false
//            }
//    }
    
    static func buildEntries(from rawData: [ResponseIndex], with timestamps: Set<String>, in currencyRate: String? = "1") -> [Entry] {
        let rawDataFiltered = self.filter(rawData: rawData, byTimestamps: timestamps)
        
        var entries: [Entry] = self.parse(from: rawDataFiltered)
        
        if let rateString = currencyRate, let rate = Double(rateString) {
            entries = self.convert(entries: entries, toRate: rate)
        }
        
        return entries
    }
    
    static func filter(rawData: [ResponseIndex], byTimestamps timestamps: Set<String>) -> [ResponseIndex] {
        return rawData.filter {
            timestamps.contains($0.ID.split(separator: "-").first.map(String.init) ?? "")
        }
    }
    
    static func parse(from rawData: [ResponseIndex]) -> [Entry] {
        var entries: [Entry] = []
        for priceIndex in rawData {
            let timestampString = priceIndex.ID.split(separator: "-").first.map(String.init) ?? ""
            if let value = priceIndex.Values["price"],
               let priceValue = Double(value),
               let timestamp = Double(timestampString) {
                let date = Date(timeIntervalSince1970: timestamp)
//                entries[timestamp] = PriceData(price: priceValue)
                entries.append((price: priceValue, timestamp: timestamp, key: timestampString, date: date))
            } else {
                print("Failed to convert priceValue toDouble \(priceIndex.Values["price"] ?? "")")
            }
        }
        return entries
    }
    
    static func convert(entries data: [Entry], toRate rate: Double) -> [Entry] {
        return data.map {
            (price: $0.price * rate, timestamp: $0.timestamp, key: $0.key, date: $0.date)
        }
    }
    
//    func minMaxEntries() -> (min: Double, max: Double)? {
//        guard let firstEntry = entries.first?.value else {
//            return nil
//        }
//
//        var min = firstEntry.price
//        var max = firstEntry.price
//
//        for entry in entries.values {
//            if entry.price < min {
//                min = entry.price
//            }
//            if entry.price > max {
//                max = entry.price
//            }
//        }
//
//        return (min, max)
//    }
}

struct PriceData {
    var price: Double
}

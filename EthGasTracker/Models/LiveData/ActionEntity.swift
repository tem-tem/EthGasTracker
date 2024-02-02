//
//  Action.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

typealias ActionEntityGroups = [Dictionary<String, [ActionEntity]>.Element]

func addSpacesToCamelCase(_ str: String) -> String {
    var result = ""
    for char in str {
        if char.isUppercase {
            result.append(" ")
        }
        result.append(char)
    }
    result.removeFirst()
    return result
}

struct ActionEntity {
    typealias Entry = (normal: Double, fast: Double, index: Int, timestamp: Double, date: Date)
    let entries: [Entry]
    let metadata: Metadata
    
    init(rawAction: Action, gasEntries: [GasDataEntity.Entry], priceEntries: [PriceDataEntity.Entry], isPinned: Bool) {
        self.metadata = Metadata(
            name: rawAction.name.uppercased(),
            groupName: addSpacesToCamelCase(rawAction.groupName),
            key: rawAction.key,
            limit: rawAction.limit,
            pinned: isPinned
        )
        
        var calcedEntries: [Entry] = []
        for gasEntry in gasEntries {
            if let priceEntry = priceEntries.first(where: { $0.timestamp == gasEntry.timestamp }),
               let normalEthCost = Double(String(format: "%.6f", (gasEntry.normal * metadata.limit) / 1e9)),
               let fastEthCost = Double(String(format: "%.6f", (gasEntry.fast * metadata.limit) / 1e9))
            {
                let normal = normalEthCost * priceEntry.price
                let fast = fastEthCost * priceEntry.price
                calcedEntries.append((
                    normal: normal,
                    fast: fast,
                    index: gasEntry.index,
                    timestamp: gasEntry.timestamp,
                    date: gasEntry.date
                ))
            }
        }
        
        self.entries = calcedEntries
    }
    
    static func calcCost(for limit: Double, ethPrice: Double, gas: Double) -> Double {
        if let costInEth = Double(String(format: "%.6f", (gas * limit) / 1e9)) {
            let costInFiat = costInEth * ethPrice
            return costInFiat
        } else {
            return 0
        }
    }
    
//    func lastEntry() -> (key: String, value: NormalFast)? {
//        guard let lastTimestampKey = entries.keys.map({ Int($0) ?? 0 }).max(), let lastTimestamp = entries[String(lastTimestampKey)] else {
//            return nil
//        }
//        return (String(lastTimestampKey), lastTimestamp)
//    }
//    
//    func getEntriesDict() -> [(key: String, value: NormalFast)] {
//        return entries.map { (key: $0.key, value: $0.value) }
//            .sorted { (lhs, rhs) in
//                // Convert keys to integers and compare
//                if let lhsKey = Int(lhs.key), let rhsKey = Int(rhs.key) {
//                    return lhsKey < rhsKey
//                }
//                return false
//            }
//    }
//    
//    func minMaxEntries(forFast speedTypeIsFast: Bool) -> (min:Double, max:Double)? {
//        guard let firstEntry = entries.first?.value else {
//            return nil
//        }
//
//        var min:Double
//        var max:Double
//
//        if speedTypeIsFast {
//            min = firstEntry.fast
//            max = firstEntry.fast
//            for entry in entries.values {
//                if entry.fast < min {
//                    min = entry.fast
//                }
//                if entry.fast > max {
//                    max = entry.fast
//                }
//            }
//        } else {
//            min = firstEntry.normal
//            max = firstEntry.normal
//            for entry in entries.values {
//                if entry.normal < min {
//                    min = entry.normal
//                }
//                if entry.normal > max {
//                    max = entry.normal
//                }
//            }
//        }
//
//        return (min, max)
//    }
}

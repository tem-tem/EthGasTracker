//
//  Action.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

typealias ActionEntityGroups = [Dictionary<String, [ActionEntity]>.Element]

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
    
    func minMaxEntries(forFast speedTypeIsFast: Bool) -> (min:Double, max:Double)? {
        guard let firstEntry = entries.first?.value else {
            return nil
        }

        var min:Double
        var max:Double

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

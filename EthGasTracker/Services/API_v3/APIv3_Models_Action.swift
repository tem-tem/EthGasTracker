//
//  APIv3_Models_Action.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

struct Action: Codable {
    let name: String
    let groupName: String
    let key: String
    let limit: Int64
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


typealias GroupedActions = [Dictionary<String, [ActionEntity]>.Element]

func normalizeAndGroupActions(from response: APIv3_GetLatestResponse, defaultOnly: Bool = false) -> GroupedActions {
    let normalizedGas = response.indexes.normalizedGas

    var ethPrices: [String: Float] = [:]
    for priceIndex in response.indexes.eth_price {
        if let price = Float(priceIndex.Values["price"] ?? "") {
            let timestamp = priceIndex.ID.split(separator: "-").first ?? ""
            
            if let rateString = response.currencyRate, let rate = Float(rateString) {
                ethPrices[String(timestamp)] = price * rate
            } else {
                ethPrices[String(timestamp)] = price
            }
        }
    }

    let actionsToReturn = defaultOnly ? response.defaultActions : response.actions
    
    return groupActions(actions: actionsToReturn, normalizedGas: normalizedGas, ethPrices: ethPrices)
}

private func groupActions(actions: [String: Action], normalizedGas: [String: NormalFast], ethPrices: [String: Float]) -> GroupedActions {
    var actionEntities: [String: [ActionEntity]] = [:]
    for (_, rawAction) in actions {
        let actionEntity = normalizeAction(rawAction: rawAction, normalizedGas: normalizedGas, ethPrices: ethPrices)
        
        actionEntities[rawAction.groupName, default: []].append(actionEntity)
    }
    
    return actionEntities.map { $0 }
}

private func normalizeAction(rawAction: Action, normalizedGas: [String: NormalFast], ethPrices: [String: Float]) -> ActionEntity {
    let metadata = Metadata(name: rawAction.name, groupName: rawAction.groupName, key: rawAction.key, limit: rawAction.limit)
    
    var entries: [String: NormalFast] = [:]
    var brokenTimestamps: [String] = []
    var brokenTimestamps2: [String] = []
    for (timestamp, gasEntry) in normalizedGas {
//        print("gas timestamp: \(timestamp)")
        let normal = (Float(String(format: "%.6f", (gasEntry.normal * Float(metadata.limit)) / 1e9)) ?? 0) * (ethPrices[timestamp] ?? 0)
        let fast = (Float(String(format: "%.6f", (gasEntry.fast * Float(metadata.limit)) / 1e9)) ?? 0) * (ethPrices[timestamp] ?? 0)
        if (normal == 0 || fast == 0) {
            brokenTimestamps.append(timestamp)
            continue
        }
        entries[timestamp] = NormalFast(normal: normal, fast: fast)
    }

    return ActionEntity(entries: entries, metadata: metadata)
}

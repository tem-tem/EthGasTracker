//
//  API_v2_Structs.swift
//  EthGasTracker
//
//  Created by Tem on 11/5/23.
//

import Foundation
import SwiftUI

struct APIv2_GetLatestResponse: Codable {
    let actions: [String: Action]
    let currentStats: CurrentStats
    let defaultActions: [String: Action]
    let indexes: Indexes
    let currencyRate: String?
}

struct GasLevel {
    let currentStats: CurrentStats
    let currentGas: Float
    
    init(currentStats: CurrentStats, currentGas: Float) {
        self.currentStats = currentStats
        self.currentGas = currentGas
    }

    var level: Int {
        // Calculate the level based on the percentiles
        switch currentGas {
        case ...currentStats.min:
            return 0
        case currentStats.min..<currentStats.p5:
            return 1
        case currentStats.p5..<currentStats.p25:
            return 2
        case currentStats.p25..<currentStats.p75:
            // Calculate a level between 2 and 8 based on where currentGas falls within the interquartile range
            let interquartileRange = currentStats.p75 - currentStats.p25
            let interquartilePosition = currentGas - currentStats.p25
            let interquartileRatio = interquartilePosition / interquartileRange
            return 3 + Int(interquartileRatio * 4) // Scale it to a range of 3-7
        case currentStats.p75...currentStats.p95:
            return 8
        case currentStats.p95...currentStats.max:
            return 9
        case currentStats.max...:
            return 10
        default:
            return -1 // Represents an error or unknown level
        }
    }
    
    var color: Color {
        return GasLevel.getColor(for: self.level)
    }
    
    var label: String {
        return GasLevel.getLabel(for: self.level)
    }

    static func getColor(for level: Int) -> Color {
        switch level {
        case 0...2:
            return Color.accentColor
        case 3...7:
            return Color(.systemBlue) // This now represents a range within the usual values
        case 8...9:
            return Color(.systemOrange)
        case 10:
            return Color(.systemRed)
        default:
            return Color(.systemGray)
        }
    }

    static func getLabel(for level: Int) -> String {
        switch level {
        case 0:
            return "EXCEPTIONALLY LOW"
        case 1:
            return "LOW"
        case 2:
            return "MODERATELY LOW"
        case 3...7:
            return "NORMAL" // This now represents a range within the usual values
        case 8:
            return "ELEVATED"
        case 9:
            return "HIGH"
        case 10:
            return "PEAK"
        default:
            return "Unknown"
        }
    }
    
    static func getDescription(for level: Int) -> String {
        switch level {
        case 0:
            return "Below the typical minimum."
        case 1:
            return "Between the typical minimum and lower 5%."
        case 2:
            return "Within the 5th to 25th percentile range."
        case 3...7:
            return "Within the 25th to 75th percentile, reflecting average gas prices."
        case 8:
            return "Above average but within the 75th to 95th percentile."
        case 9:
            return "Between the 95th percentile and near peak levels."
        case 10:
            return "Surpassing the typical maximum average."
        default:
            return "Status: Unknown"
        }
    }
}

struct CurrentStats: Codable {
    let minuteOfDay: Int
    let max: Float
    let avg: Float
    let min: Float
    let p5: Float
    let p25: Float
    let p50: Float
    let p75: Float
    let p95: Float
    let measureName: String

    enum CodingKeys: String, CodingKey {
        case minuteOfDay = "minute_of_day"
        case max, avg, min, p5, p25, p50, p75, p95, measureName = "measure_name"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        minuteOfDay = try Int(container.decode(String.self, forKey: .minuteOfDay)) ?? 0
        max = try Float(container.decode(String.self, forKey: .max)) ?? 0.0
        avg = try Float(container.decode(String.self, forKey: .avg)) ?? 0.0
        min = try Float(container.decode(String.self, forKey: .min)) ?? 0.0
        p5 = try Float(container.decode(String.self, forKey: .p5)) ?? 0.0
        p25 = try Float(container.decode(String.self, forKey: .p25)) ?? 0.0
        p50 = try Float(container.decode(String.self, forKey: .p50)) ?? 0.0
        p75 = try Float(container.decode(String.self, forKey: .p75)) ?? 0.0
        p95 = try Float(container.decode(String.self, forKey: .p95)) ?? 0.0
        measureName = try container.decode(String.self, forKey: .measureName)
    }

    static func placeholder() -> CurrentStats {
        // Placeholder JSON data for CurrentStats
        let jsonData = """
        {
            "minute_of_day": "0",
            "max": "0.0",
            "avg": "0.0",
            "min": "0.0",
            "p5": "0.0",
            "p25": "0.0",
            "p50": "0.0",
            "p75": "0.0",
            "p95": "0.0",
            "measure_name": "Unknown"
        }
        """.data(using: .utf8)!

        // Decode the JSON to CurrentStats
        let decoder = JSONDecoder()
        do {
            let stats = try decoder.decode(CurrentStats.self, from: jsonData)
            return stats
        } catch {
            fatalError("Failed to decode placeholder CurrentStats: \(error)")
        }
    }
}

struct Action: Codable {
    let name: String
    let groupName: String
    let key: String
    let limit: Int64
}

struct Indexes: Codable {
    let eth_price: [PriceIndex]
    let gas: [GasIndex]
}

extension Indexes {
    // New variable to store timestamps of gas records
    private var gasTimestamps: Set<String> {
        return Set(gas.map { $0.ID.split(separator: "-").first.map(String.init) ?? "" })
    }

    var normalizedEthPrice: PriceDataEntity {
        var entries: [String: PriceData] = [:]
        
        // Filter the eth_price to only include timestamps that are present in the gas records
        let filteredEthPrice = eth_price.filter {
            gasTimestamps.contains($0.ID.split(separator: "-").first.map(String.init) ?? "")
        }
        
        // Proceed with the normalization process only for filtered records
        for priceIndex in filteredEthPrice {
            let timestamp = priceIndex.ID.split(separator: "-").first.map(String.init) ?? ""
            if let value = priceIndex.Values["price"], let priceValue = Float(value) {
                entries[timestamp] = PriceData(price: priceValue)
            } else {
                print("Failed to convert priceValue to Float \(priceIndex.Values["price"] ?? "")")
            }
        }
        
        return PriceDataEntity(entries: entries)
    }
    
    func getNormalizedEthPrice(in rate: Float) -> PriceDataEntity {
        var entries: [String: PriceData] = normalizedEthPrice.entries
        
        for (key, value) in entries {
            entries[key] = PriceData(price: value.price * rate)
        }
        
        return PriceDataEntity(entries: entries)
    }
}

extension Indexes {
    private var ethTimestamps: Set<String> {
        return Set(eth_price.map { $0.ID.split(separator: "-").first.map(String.init) ?? "" })
    }
    
    typealias ListEntry = (index: Int, timestamp: Date, normal: Float, fast: Float, key: String)
    
    var normalizedGas: [String: NormalFast] {
        // Filter the gas to only include timestamps that are present in the eth_price records
        let filteredGas = gas.filter {
            ethTimestamps.contains($0.ID.split(separator: "-").first.map(String.init) ?? "")
        }
        
        return filteredGas.reduce(into: [:]) { result, gasIndex in
            let timestamp = gasIndex.ID.split(separator: "-").first ?? ""
            if let normalString = gasIndex.Values["normal"], let normal = Float(normalString), let fastString = gasIndex.Values["fast"],
               let fast = Float(fastString) {
                result[String(timestamp)] = NormalFast(normal: normal, fast: fast)
            } else {
                print("Failed to convert gasIndex to Float \(gasIndex.Values)")
            }
        }
    }
    
    func getEntriesList() -> [ListEntry] {
        return normalizedGas.map { entry in
            // Convert the key (timestamp in String format) to Double
            if let timestampValue = Double(entry.key) {
                // Convert the timestamp from milliseconds to seconds for Date init
                let date = Date(timeIntervalSince1970: timestampValue / 1000)
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
    
    func findMinMax() -> (normalMin: Float?, normalMax: Float?, fastMin: Float?, fastMax: Float?) {
        let entries = getEntriesList()
        
        let normalValues = entries.map { $0.normal }
        let fastValues = entries.map { $0.fast }
        
        let normalMin = normalValues.min()
        let normalMax = normalValues.max()
        
        let fastMin = fastValues.min()
        let fastMax = fastValues.max()
        
        return (normalMin: normalMin, normalMax: normalMax, fastMin: fastMin, fastMax: fastMax)
    }
}


struct PriceIndex: Codable {
    let ID: String
    let Values: [String: String]
}

struct GasIndex: Codable {
    let ID: String
    let Values: [String: String]
}

typealias GroupedActions = [Dictionary<String, [ActionEntity]>.Element]

func normalizeAndGroupActions(from response: APIv2_GetLatestResponse, defaultOnly: Bool = false) -> GroupedActions {
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



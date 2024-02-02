//
//  APIv3_Models_Indexes.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

struct Indexes: Codable {
    let eth_price: [PriceIndex]
    let gas: [GasIndex]
}

struct PriceIndex: Codable {
    let ID: String
    let Values: [String: String]
}

struct GasIndex: Codable {
    let ID: String
    let Values: [String: String]
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

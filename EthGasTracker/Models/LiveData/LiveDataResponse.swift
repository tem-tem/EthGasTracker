//
//  ApiResponse.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

struct LiveDataResponse: Codable {
    let actions: [String: Action]
    let defaultActions: [String: Action]
    let currentStats: CurrentStats
    let indexes: Indexes
    let currencyRate: String?
    let btcIndexes: BTCIndexes
}

struct Action: Codable {
    let name: String
    let groupName: String
    let key: String
    let limit: Double
}

struct Indexes: Codable {
    let eth_price: [ResponseIndex]
    let gas: [ResponseIndex]
    
    private var gasTimestamps: Set<String> {
        Set(gas.map { $0.ID.split(separator: "-").first.map(String.init) ?? "" })
    }
    private var ethTimestamps: Set<String> {
        Set(eth_price.map { $0.ID.split(separator: "-").first.map(String.init) ?? "" })
    }
    
    var commonTimestamps: Set<String> {
        gasTimestamps.intersection(ethTimestamps)
    }
}

struct BTCIndexes: Codable {
    let btcFees: BTCFees
    let btcPrice: [ResponseIndex]
    
    var price: Int {
        Int(btcPrice.last?.Values["price"] ?? "0") ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case btcFees = "btc_fees"
        case btcPrice = "btc_price"
    }
}

struct BTCFees: Codable {
    let histogram: String
    let rate: String
    
    var rateInt: Int {
        Int(round(Double(rate) ?? 0.0))
    }

    var histogramArray: [[Int]]? {
        // Attempt to parse the histogram string as a JSON array
        guard let data = histogram.data(using: .utf8) else { return nil }
        do {
            return try JSONDecoder().decode([[Int]].self, from: data)
        } catch {
            print("Error parsing histogram data: \(error)")
            return nil
        }
    }
    
    var consolidatedHistogram: [Int: [Int]] {
        var histogramMap: [Int: [Int]] = [:]

        guard let histogramArray = self.histogramArray else { return [:] }

        for feeTime in histogramArray {
            guard let fee = feeTime.first, let time = feeTime.last else { continue }
            
            // Append fee to the array for the current time, initializing if necessary
            if var fees = histogramMap[time] {
                fees.append(fee)
                histogramMap[time] = fees
            } else {
                histogramMap[time] = [fee]
            }
        }

        // Sort the arrays of fees for each time
        for (time, fees) in histogramMap {
            histogramMap[time] = fees.sorted()
        }

        return histogramMap
    }
}


struct ResponseIndex: Codable {
    let ID: String
    let Values: [String: String]
}

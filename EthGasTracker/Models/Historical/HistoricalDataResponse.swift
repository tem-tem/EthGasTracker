//
//  HistoricalDataResponse.swift
//  EthGasTracker
//
//  Created by Tem on 1/9/24.
//

import Foundation

struct HistoryResponse: Codable {
    var data: [String: [HistoryRecord]]
}

struct HistoryRecord: Codable {
    let ID: String
    let Values: HourValues
}

struct HourValues: Codable {
    let data: String
    let timestamp: String
}


struct HistoricalDataKey: Hashable {
    let timestamp: TimeInterval
    let measureName: String
}

typealias GroupedHistoricalData = [HistoricalDataKey: [HistoricalData]]

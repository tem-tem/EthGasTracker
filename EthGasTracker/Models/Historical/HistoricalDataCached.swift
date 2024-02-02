//
//  HistoricalDataCached.swift
//  EthGasTracker
//
//  Created by Tem on 1/9/24.
//

import Foundation

struct HistoricalDataCached {
    let gasListNormal: [HistoricalData]
    let gasListFast: [HistoricalData]
    let priceList: [HistoricalData]
    let timestamp: Date
    let safeRanges: SafeRanges
    let fullRanges: SafeRanges
    let lifespan: TimeInterval
    
    var expirationDate: Date {
        return timestamp.addingTimeInterval(lifespan)
    }
    
    static func placeholder() -> HistoricalDataCached {
        return HistoricalDataCached(
            gasListNormal: [],
            gasListFast: [],
            priceList: [],
            timestamp: Date(timeIntervalSince1970: 0),
            safeRanges:
                SafeRanges(
                    normal: MinMax(min: 0.0, max: 0.0),
                    fast: MinMax(min: 0.0, max: 0.0)
                ),
            fullRanges:
                SafeRanges(
                    normal: MinMax(min: 0.0, max: 0.0),
                    fast: MinMax(min: 0.0, max: 0.0)
                ),
            lifespan: 0)
    }
    
    static let oneMinute: TimeInterval = 60 // 60 seconds
    static let fifteenMinutes: TimeInterval = 15 * 60 // 15 minutes
    static let twoHours: TimeInterval = 2 * 60 * 60 // 2 hours
    static let eightHours: TimeInterval = 8 * 60 * 60 // 8 hours
}

//
//  HistoricalData.swift
//  EthGasTracker
//
//  Created by Tem on 12/15/23.
//

import Foundation

extension AppDelegate {
    func fetchHistoricalData_1hr() {
        if (self.historicalData_1h.expirationDate > Date.now) {
            return
        }
        self.api_v3.getHistory(for: HistoryRange.hour) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.historicalData_1h = self.getHistoricalDataCached(from: data)
                }
            case .failure(let error):
                print("error while fetching hourly data")
                print(error)
            }
        }
    }
    
    func fetchHistoricalData_day() {
        if (self.historicalData_1d.expirationDate > Date.now) {
            return
        }
        self.api_v3.getHistory(for: HistoryRange.day) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.historicalData_1d = self.getHistoricalDataCached(from: data)
                }
            case .failure(let error):
                print("error while fetching hourly data")
                print(error)
            }
        }
    }
    
    func fetchHistoricalData_week() {
        if (self.historicalData_1w.expirationDate > Date.now) {
            return
        }
        self.api_v3.getHistory(for: HistoryRange.week) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.historicalData_1w = self.getHistoricalDataCached(from: data)
                }
            case .failure(let error):
                print("error while fetching hourly data")
                print(error)
            }
        }
    }
    
    func fetchHistoricalData_month() {
        if (self.historicalData_1m.expirationDate > Date.now) {
            return
        }
        self.api_v3.getHistory(for: HistoryRange.month) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.historicalData_1m = self.getHistoricalDataCached(from: data)
                }
            case .failure(let error):
                print("error while fetching hourly data")
                print(error)
            }
        }
    }
    
    
    private func getHistoricalDataCached(from data: GroupedHistoricalData) -> HistoricalDataCahced {
        let list = getOrderedHistoricalData(from: data)
        var listNormal = list.filter { $0.measureName == "normal" }
        var listFast = list.filter { $0.measureName == "fast" }
        let price = list.filter { $0.measureName == "price" }
        
        for priceItem in price {
            if let index = listNormal.firstIndex(where: { $0.date == priceItem.date }) {
                listNormal[index].price = priceItem.avg * self.currencyRate
            }

            if let index = listFast.firstIndex(where: { $0.date == priceItem.date }) {
                listFast[index].price = priceItem.avg * self.currencyRate
            }
        }
        
        return HistoricalDataCahced(
            gasListNormal: listNormal,
            gasListFast: listFast,
            priceList: price,
            timestamp: Date.now,
            safeRanges: SafeRanges(
                normal: MinMax(min: listNormal.map { $0.avg }.min() ?? 0, max: listNormal.map { $0.avg }.max() ?? 10),
                fast: MinMax(min: listFast.map { $0.avg }.min() ?? 0, max: listFast.map { $0.avg }.max() ?? 10)
                ),
            fullRanges: SafeRanges(
                normal: MinMax(min: listNormal.map { $0.p5 }.min() ?? 0, max: listNormal.map { $0.p95 }.max() ?? 10),
                fast: MinMax(min: listFast.map { $0.p5 }.min() ?? 0, max: listFast.map { $0.p95 }.max() ?? 10)
                ),
            lifespan: HistoricalDataCahced.oneMinute
        )
    }
}

struct HistoricalDataCahced {
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
    
    static func placeholder() -> HistoricalDataCahced {
        return HistoricalDataCahced(gasListNormal: [], gasListFast: [], priceList: [], timestamp: Date(timeIntervalSince1970: 0), safeRanges: SafeRanges(normal: MinMax(min: 0.0, max: 0.0), fast: MinMax(min: 0.0, max: 0.0)),fullRanges: SafeRanges(normal: MinMax(min: 0.0, max: 0.0), fast: MinMax(min: 0.0, max: 0.0)), lifespan: 0)
    }
    
    static let oneMinute: TimeInterval = 60 // 60 seconds
    static let fifteenMinutes: TimeInterval = 15 * 60 // 15 minutes
    static let twoHours: TimeInterval = 2 * 60 * 60 // 2 hours
    static let eightHours: TimeInterval = 8 * 60 * 60 // 8 hours
}

struct SafeRanges {
    let normal: MinMax
    let fast: MinMax
}

struct MinMax {
    let min: Float
    let max: Float
}

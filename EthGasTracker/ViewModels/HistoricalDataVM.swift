//
//  HistoricalDataVM.swift
//  EthGasTracker
//
//  Created by Tem on 1/9/24.
//

import Foundation
import SwiftUI

class HistoricalDataVM: ObservableObject {
    let apiManager: APIManager
    
    @AppStorage("currencyRate") var currencyRate = 1.0
    
    @Published var hour: HistoricalDataCached = HistoricalDataCached.placeholder()
    @Published var day: HistoricalDataCached = HistoricalDataCached.placeholder()
    @Published var week: HistoricalDataCached = HistoricalDataCached.placeholder()
    @Published var month: HistoricalDataCached = HistoricalDataCached.placeholder()
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    func fetch(range: HistoryRange) {
        if (self.getHistoricalDataCached(from: range).expirationDate > Date.now) {
            return
        }
        self.apiManager.getHistory(for: range) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.updateHistoricalDataCached(from: range, with: data)
                }
            case .failure(let error):
                print("error while fetching hourly data")
                print(error)
            }
        }
    }
    
    private func getHistoricalDataCached(from range: HistoryRange) -> HistoricalDataCached {
        switch range {
        case .hour:
            return self.hour
        case .day:
            return self.day
        case .week:
            return self.week
        case .month:
            return self.month
        }
    }
    
    private func updateHistoricalDataCached(from range: HistoryRange, with data: GroupedHistoricalData) {
        let historicalDataCached = buildHistoricalDataCached(for: range, with: data)
        switch range {
        case .hour:
            self.hour = historicalDataCached
        case .day:
            self.day = historicalDataCached
        case .week:
            self.week = historicalDataCached
        case .month:
            self.month = historicalDataCached
        }
    }
    
    private func buildHistoricalDataCached(for range: HistoryRange, with data: GroupedHistoricalData) -> HistoricalDataCached {
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
        
        return HistoricalDataCached(
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
            lifespan: getLifespan(for: range)
        )
    }
    
    private func getOrderedHistoricalData(from groupedData: GroupedHistoricalData) -> [HistoricalData] {
        let allData = groupedData.values.flatMap { $0 }
        return allData.sorted { $0.date < $1.date }
    }
    
    private func getLifespan(for range: HistoryRange) -> TimeInterval {
        switch range {
        case .hour:
            return HistoricalDataCached.oneMinute
        case .day:
            return HistoricalDataCached.fifteenMinutes
        case .week:
            return HistoricalDataCached.twoHours
        case .month:
            return HistoricalDataCached.eightHours
            
        }
    }
    
//    func fetch(range: HistoryRange) {
//        if (self.historicalData_1h.expirationDate > Date.now) {
//            return
//        }
//        self.api_v3.getHistory(for: HistoryRange.hour) { result in
//            switch result {
//            case .success(let data):
//                DispatchQueue.main.async {
//                    self.historicalData_1h = self.getHistoricalDataCached(from: data)
//                }
//            case .failure(let error):
//                print("error while fetching hourly data")
//                print(error)
//            }
//        }
//    }
}

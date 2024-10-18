//
//  Utils.swift
//  EthGasTracker
//
//  Created by Tem on 10/10/24.
//

import Foundation

func normalizeChartData<T>(_ rawEntries: [T], valueKeyPath: KeyPath<T, Double>, indexKeyPath: KeyPath<T, Int>) -> [NormilizedChartData] {
    rawEntries.map { entry in
        NormilizedChartData(
            index: entry[keyPath: indexKeyPath],
            value: entry[keyPath: valueKeyPath]
        )
    }
}

func normalizeChartData(from cachedData: HistoricalDataCached, valueType: ValueType) -> [NormilizedChartData] {
    let rawEntries: [HistoricalData]
    switch valueType {
    case .normalGas: rawEntries = cachedData.gasListNormal
    case .fastGas: rawEntries = cachedData.gasListFast
    case .price: rawEntries = cachedData.priceList
    }
    
    return rawEntries.enumerated().map { (index, entry) in
        NormilizedChartData(
            index: index,
            value: entry.avg
        )
    }
}


enum ValueType {
    case normalGas
    case fastGas
    case price
}

struct NormilizedChartData {
    var index: Int
    var value: Double
    var selectedValue: Double?
}

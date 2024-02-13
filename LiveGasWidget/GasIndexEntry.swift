//
//  GasIndexEntry.swift
//  EthGasTracker
//
//  Created by Tem on 2/10/24.
//

import Foundation
import WidgetKit

struct GasIndexEntry: TimelineEntry {
    let date: Date
    let gas: Double
    let ethPrice: Double
    let gasDataEntity: GasDataEntity
    let gasLevel: GasLevel
    let actions: [CustomActionEntity]
    
    static let placeholder = GasIndexEntry(
        date: Date(),
        gas: 88,
        ethPrice: 8888,
        gasDataEntity: GasDataEntity(from: [], with: []),
        gasLevel: GasLevel(
            currentStats: CurrentStats.placeholder(),
            currentGas: 88
        ),
        actions: [
            CustomActionEntity.placeholder()
        ]
    )
}

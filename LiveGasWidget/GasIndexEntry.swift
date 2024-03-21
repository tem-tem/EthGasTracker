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
    let btcDataEntity: BtcDataEntity
    let isPlaceholder: Bool
    
    static let placeholder = GasIndexEntry(
        date: Date(),
        gas: 88,
        ethPrice: 8888,
        gasDataEntity: GasDataEntity(from: [], with: []),
        gasLevel: GasLevel(
            currentStats: CurrentStats.placeholder(),
            currentGas: 88
        ),
        actions: CustomActionEntity.placeholders(amount: 10),
        btcDataEntity: BtcDataEntity(price: 69420, rate: 69, histogram: [:]),
        isPlaceholder: true
    )
    
    static func generatePlaceholder(customActionDM: CustomActionDataManager) -> GasIndexEntry {
        GasIndexEntry(
            date: Date(),
            gas: 88,
            ethPrice: 8888,
            gasDataEntity: GasDataEntity(from: [], with: []),
            gasLevel: GasLevel(
                currentStats: CurrentStats.placeholder(),
                currentGas: 88
            ),
            actions: customActionDM.actions,
            btcDataEntity: BtcDataEntity(price: 69420, rate: 69, histogram: [:]),
            isPlaceholder: true
        )
    }
}

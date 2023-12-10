//
//  WIdgetProvider.swift
//  EthGasTracker
//
//  Created by Tem on 9/2/23.
//

import Foundation
import WidgetKit

struct GasIndexProvider: TimelineProvider {
    let api = APIv2()
    let dataManager = DataManager()
    func placeholder(in context: Context) -> GasIndexEntry {
        GasIndexEntry(date: Date(), gasIndexEntries: [], gasLevel: GasLevel(currentStats: CurrentStats.placeholder(), currentGas: 0.0))
    }

    func getSnapshot(in context: Context, completion: @escaping (GasIndexEntry) -> Void) {
        let entry = GasIndexEntry(date: Date(), gasIndexEntries: [], gasLevel: GasLevel(currentStats: CurrentStats.placeholder(), currentGas: 0.0))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GasIndexEntry>) -> Void) {
//        dataManager.getEntities(amount: 1, actions: "") { result in
//            var gasIndexEntries: [GasIndexEntity.ListEntry] = []
//            
//            if case .success(let entities) = result {
//                gasIndexEntries = entities.gasIndexEntity.getEntriesList()
//            }
//            
//            let entry = GasIndexEntry(date: Date(), gasIndexEntries: gasIndexEntries)
//            let timeline = Timeline(entries: [entry], policy: .atEnd)
//            completion(timeline)
//        }
        api.getLatest(currency: "USD") { result in
            var gasIndexEntries: [GasIndexEntity.ListEntry] = []
            var gasLevel: GasLevel = GasLevel(currentStats: CurrentStats.placeholder(), currentGas: 0.0)
            
            if case .success(let response) = result {
                gasIndexEntries = response.indexes.getEntriesList()
                gasLevel = GasLevel(currentStats: response.currentStats, currentGas: gasIndexEntries.last?.normal ?? 0.0)
            }
            
            let entry = GasIndexEntry(date: Date(), gasIndexEntries: gasIndexEntries, gasLevel: gasLevel)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct GasIndexEntry: TimelineEntry {
    let date: Date
    let gasIndexEntries: [GasIndexEntity.ListEntry]
    let gasLevel: GasLevel
}

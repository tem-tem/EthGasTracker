//
//  WIdgetProvider.swift
//  EthGasTracker
//
//  Created by Tem on 9/2/23.
//

import Foundation
import WidgetKit

struct GasIndexProvider: TimelineProvider {
    let dataManager = DataManager()

    func placeholder(in context: Context) -> GasIndexEntry {
        GasIndexEntry(date: Date(), gasIndexEntries: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (GasIndexEntry) -> Void) {
        let entry = GasIndexEntry(date: Date(), gasIndexEntries: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GasIndexEntry>) -> Void) {
        dataManager.getEntities(amount: 1) { result in
            var gasIndexEntries: [GasIndexEntity.ListEntry] = []
            
            if case .success(let entities) = result {
                gasIndexEntries = entities.gasIndexEntity.getEntriesList()
            }
            
            let entry = GasIndexEntry(date: Date(), gasIndexEntries: gasIndexEntries)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct GasIndexEntry: TimelineEntry {
    let date: Date
    let gasIndexEntries: [GasIndexEntity.ListEntry]
}

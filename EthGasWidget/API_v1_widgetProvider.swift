////
////  API_v1_widgetProvider.swift
////  EthGasWidgetExtension
////
////  Created by Tem on 11/4/23.
////
//
//import Foundation
//import WidgetKit
//
//struct API_V1_widgetProvider: TimelineProvider {
//    let dataManager = DataManager()
//
//    func placeholder(in context: Context) -> GasIndexEntry {
//        GasIndexEntry(date: Date(), gasIndexEntries: [])
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (GasIndexEntry) -> Void) {
//        let entry = GasIndexEntry(date: Date(), gasIndexEntries: [])
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<GasIndexEntry>) -> Void) {
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
//    }
//}
//
//struct GasIndexEntry: TimelineEntry {
//    let date: Date
//    let gasIndexEntries: [GasIndexEntity.ListEntry]
//}

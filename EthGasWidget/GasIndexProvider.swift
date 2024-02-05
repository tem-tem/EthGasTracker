////
////  WIdgetProvider.swift
////  EthGasTracker
////
////  Created by Tem on 9/2/23.
////
//
//import Foundation
//import WidgetKit
//
//struct GasIndexProvider: TimelineProvider {
//    let apiManager = APIManager()
//    
//    func placeholder(in context: Context) -> GasIndexEntry {
//        GasIndexEntry.placeholder
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (GasIndexEntry) -> Void) {
//        let entry = GasIndexEntry.placeholder
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<GasIndexEntry>) -> Void) {
//        SharedDataRepository.shared.fetchDataIfNeeded { result in
//            switch result {
//            case .success(let data):
//                let timeline = Timeline(entries: [data], policy: .atEnd)
//                completion(timeline)
//            case .failure(let error):
//                print("Error in the gas index provider: \(error)")
//            }
//        }
//    }
//}
//
//struct GasIndexEntry: TimelineEntry {
//    let date: Date
//    let gasDataEntity: GasDataEntity
//    let gasLevel: GasLevel
//    let actions: [ActionEntity]
//    
//    static let placeholder = GasIndexEntry(
//        date: Date(),
//        gasDataEntity: GasDataEntity(from: [], with: []),
//        gasLevel: GasLevel(
//            currentStats: CurrentStats.placeholder(),
//            currentGas: 88
//        ),
//        actions: [
//            ActionEntity(rawAction: Action(name: "USDT Transfer", groupName: "Ethereum", key: "Key", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
//            ActionEntity(rawAction: Action(name: "ETH Transfer", groupName: "Ethereum", key: "Key2", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
//            ActionEntity(rawAction: Action(name: "SCROLL", groupName: "NativeBridges", key: "Key3", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
//            ActionEntity(rawAction: Action(name: "Native Bridges", groupName: "NativeBridges", key: "Key3.5", limit: 300000), gasEntries: [], priceEntries: [], isPinned: false),
//            ActionEntity(rawAction: Action(name: "USDT Transfer", groupName: "Ethereum", key: "Key123", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
//            ActionEntity(rawAction: Action(name: "ETH Transfer", groupName: "Ethereum", key: "Key2$32", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
//            ActionEntity(rawAction: Action(name: "SCROLL", groupName: "NativeBridges", key: "Key3432", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
//            ActionEntity(rawAction: Action(name: "Native Bridges", groupName: "NativeBridges", key: "Key3.15", limit: 300000), gasEntries: [], priceEntries: [], isPinned: false),
//            ActionEntity(rawAction: Action(name: "STARKNET", groupName: "Native Bridges", key: "Key432", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true)
//        ]
//    )
//}

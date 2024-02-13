//
//  WIdgetProvider.swift
//  EthGasTracker
//
//  Created by Tem on 9/2/23.
//

import Foundation
import WidgetKit

struct GasIndexProvider: TimelineProvider {
    let apiManager = APIManager()
    private let actionDataManager = CustomActionDataManager()
    
    func placeholder(in context: Context) -> GasIndexEntry {
        GasIndexEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (GasIndexEntry) -> Void) {
        let entry = GasIndexEntry.placeholder
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GasIndexEntry>) -> Void) {
        SharedDataRepository.shared.fetchDataIfNeeded { result in
            switch result {
            case .success(let data):
                let timeline = Timeline(entries: [data], policy: .atEnd)
                completion(timeline)
            case .failure(let error):
                print("Error in the gas index provider: \(error)")
            }
        }
    }
}

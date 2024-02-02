//
//  GasDataEntity.swift
//  EthGasTracker
//
//  Created by Tem on 1/9/24.
//

import Foundation

struct GasDataEntity {
    typealias Entry = (index: Int, date: Date, normal:Double, fast:Double, key: String, timestamp: Double)
    
    let entries: [Entry]
    let min: Double
    let max: Double
    let lastNormal: Double
    let lastFast: Double
    
    init (from rawData: [ResponseIndex], with timestamps: Set<String>) {
        self.entries = GasDataEntity.buildEntries(from: rawData, with: timestamps)
        self.min = self.entries.map { $0.normal }.min() ?? 0
        self.max = self.entries.map { $0.normal }.max() ?? 0
        self.lastNormal = self.entries.last?.normal ?? 0
        self.lastFast = self.entries.last?.fast ?? 0
    }
    
    static func buildEntries(from rawData: [ResponseIndex], with timestamps: Set<String>) -> [Entry] {
        let rawDataFiltered = self.filter(rawData: rawData, with: timestamps)
        
        return self.parse(rawData: rawDataFiltered)
    }
    
    static func filter(rawData: [ResponseIndex], with timestamps: Set<String>) -> [ResponseIndex] {
        return rawData.filter {
            timestamps.contains($0.ID.split(separator: "-").first.map(String.init) ?? "")
        }
    }

    static func parse(rawData: [ResponseIndex]) -> [Entry] {
        let entries: [String:Entry] = rawData
            .reduce(into: [:]) { result, gasIndex in
                if let normalString = gasIndex.Values["normal"],
                   let fastString = gasIndex.Values["fast"],
                   let normal = Double(normalString),
                   let fast = Double(fastString),
                   let timestampString = gasIndex.ID.split(separator: "-").first,
                   let timestamp = Double(timestampString) {
                    let date = Date(timeIntervalSince1970: timestamp / 1000)
                    result[String(timestamp)] = (index: 0, date: date, normal: normal, fast: fast, key: String(timestamp), timestamp: timestamp)
                } else {
                    print("Failed to convert gasIndex to Double \(gasIndex.Values)")
                }
            }

        return entries.values
            .sorted { $0.timestamp < $1.timestamp }
            .enumerated()
            .map { (index, element) in
                (index: index, date: element.date, normal: element.normal, fast: element.fast, key: element.key, timestamp: element.timestamp)
            }
    }

}

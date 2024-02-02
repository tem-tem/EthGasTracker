//
//  HistoricalData.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

struct HistoricalData: Decodable, Equatable {
    let date: Date
    let max:Double
    let avg:Double
    let min:Double
    let p5:Double
    let p25:Double
    let p50:Double
    let p75:Double
    let p95:Double
    let deviation: Int
    let measureName: String
    
    var price:Double = 0.0
    
    enum CodingKeys: String, CodingKey {
        case timestamp, max, avg, min, p5, p25, p50, p75, p95, deviation
        case measureName = "measure_name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let timestamp = try container.decode(String.self, forKey: .timestamp)
        
        // Convert the timestamp string to a Date object
        guard let parsedDate = DateFormatter.iso8601Full.date(from: timestamp) else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp,
                                                   in: container,
                                                   debugDescription: "Date string does not match format expected by formatter.")
        }
        date = parsedDate
        
        max = try Double(container.decode(String.self, forKey: .max)) ?? 0.0
        avg = try Double(container.decode(String.self, forKey: .avg)) ?? 0.0
        min = try Double(container.decode(String.self, forKey: .min)) ?? 0.0
        p5 = try Double(container.decode(String.self, forKey: .p5)) ?? 0.0
        p25 = try Double(container.decode(String.self, forKey: .p25)) ?? 0.0
        p50 = try Double(container.decode(String.self, forKey: .p50)) ?? 0.0
        p75 = try Double(container.decode(String.self, forKey: .p75)) ?? 0.0
        p95 = try Double(container.decode(String.self, forKey: .p95)) ?? 0.0
        deviation = try Int(container.decode(String.self, forKey: .deviation)) ?? 0
        measureName = try container.decode(String.self, forKey: .measureName)
    }
}

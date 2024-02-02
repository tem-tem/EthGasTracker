//
//  HistoricalData.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

struct HistoricalData: Decodable, Equatable {
    let date: Date  // Now a mandatory field
    let max: Float
    let avg: Float
    let min: Float
    let p5: Float
    let p25: Float
    let p50: Float
    let p75: Float
    let p95: Float
    let deviation: Int
    let measureName: String
    
    var price: Float = 0.0
    
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
        
        max = try Float(container.decode(String.self, forKey: .max)) ?? 0.0
        avg = try Float(container.decode(String.self, forKey: .avg)) ?? 0.0
        min = try Float(container.decode(String.self, forKey: .min)) ?? 0.0
        p5 = try Float(container.decode(String.self, forKey: .p5)) ?? 0.0
        p25 = try Float(container.decode(String.self, forKey: .p25)) ?? 0.0
        p50 = try Float(container.decode(String.self, forKey: .p50)) ?? 0.0
        p75 = try Float(container.decode(String.self, forKey: .p75)) ?? 0.0
        p95 = try Float(container.decode(String.self, forKey: .p95)) ?? 0.0
        deviation = try Int(container.decode(String.self, forKey: .deviation)) ?? 0
        measureName = try container.decode(String.self, forKey: .measureName)
    }
}

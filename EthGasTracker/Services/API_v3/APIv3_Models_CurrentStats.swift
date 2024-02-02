//
//  APIv3_Models_CurrentStats.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

struct CurrentStats: Codable {
    let minuteOfDay: Int
    let max: Float
    let avg: Float
    let min: Float
    let p5: Float
    let p25: Float
    let p50: Float
    let p75: Float
    let p95: Float
    let measureName: String

    enum CodingKeys: String, CodingKey {
        case minuteOfDay = "minute_of_day"
        case max, avg, min, p5, p25, p50, p75, p95, measureName = "measure_name"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        minuteOfDay = try Int(container.decode(String.self, forKey: .minuteOfDay)) ?? 0
        max = try Float(container.decode(String.self, forKey: .max)) ?? 0.0
        avg = try Float(container.decode(String.self, forKey: .avg)) ?? 0.0
        min = try Float(container.decode(String.self, forKey: .min)) ?? 0.0
        p5 = try Float(container.decode(String.self, forKey: .p5)) ?? 0.0
        p25 = try Float(container.decode(String.self, forKey: .p25)) ?? 0.0
        p50 = try Float(container.decode(String.self, forKey: .p50)) ?? 0.0
        p75 = try Float(container.decode(String.self, forKey: .p75)) ?? 0.0
        p95 = try Float(container.decode(String.self, forKey: .p95)) ?? 0.0
        measureName = try container.decode(String.self, forKey: .measureName)
    }

    static func placeholder() -> CurrentStats {
        // Placeholder JSON data for CurrentStats
        let jsonData = """
        {
            "minute_of_day": "0",
            "max": "0.0",
            "avg": "0.0",
            "min": "0.0",
            "p5": "0.0",
            "p25": "0.0",
            "p50": "0.0",
            "p75": "0.0",
            "p95": "0.0",
            "measure_name": "Unknown"
        }
        """.data(using: .utf8)!

        // Decode the JSON to CurrentStats
        let decoder = JSONDecoder()
        do {
            let stats = try decoder.decode(CurrentStats.self, from: jsonData)
            return stats
        } catch {
            fatalError("Failed to decode placeholder CurrentStats: \(error)")
        }
    }
}

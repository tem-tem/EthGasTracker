//
//  CurrentStats.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

struct CurrentStats: Codable {
    let minuteOfDay: Int
    let max:Double
    let avg:Double
    let min:Double
    let p5:Double
    let p25:Double
    let p50:Double
    let p75:Double
    let p95:Double
    let measureName: String

    enum CodingKeys: String, CodingKey {
        case minuteOfDay = "minute_of_day"
        case max, avg, min, p5, p25, p50, p75, p95, measureName = "measure_name"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        minuteOfDay = try Int(container.decode(String.self, forKey: .minuteOfDay)) ?? 0
        max = try Double(container.decode(String.self, forKey: .max)) ?? 0.0
        avg = try Double(container.decode(String.self, forKey: .avg)) ?? 0.0
        min = try Double(container.decode(String.self, forKey: .min)) ?? 0.0
        p5 = try Double(container.decode(String.self, forKey: .p5)) ?? 0.0
        p25 = try Double(container.decode(String.self, forKey: .p25)) ?? 0.0
        p50 = try Double(container.decode(String.self, forKey: .p50)) ?? 0.0
        p75 = try Double(container.decode(String.self, forKey: .p75)) ?? 0.0
        p95 = try Double(container.decode(String.self, forKey: .p95)) ?? 0.0
        measureName = try container.decode(String.self, forKey: .measureName)
    }

    static func placeholder() -> CurrentStats {
        // Placeholder JSON data for CurrentStats
        let jsonData = """
        {
            "minute_of_day": "0",
            "max": "100.0",
            "avg": "50.0",
            "min": "10.0",
            "p5": "15.0",
            "p25": "25.0",
            "p50": "50.0",
            "p75": "75.0",
            "p95": "95.0",
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

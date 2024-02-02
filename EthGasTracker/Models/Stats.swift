//
//  StatsModel.swift
//  EthGasTracker
//
//  Created by Tem on 1/29/24.
//

import Foundation

struct StatsModel: Decodable {
    let minuteOfDay: Int
    let max:Double
    let avg:Double
    let min:Double
    let measureName: String

    enum CodingKeys: String, CodingKey {
        case minuteOfDay = "minute_of_day"
        case max, avg, min, measureName = "measure_name"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let minuteOfDayStr = try container.decode(String.self, forKey: .minuteOfDay)
        guard let minuteAsInt = Int(minuteOfDayStr) else {
            throw DecodingError.dataCorruptedError(forKey: .minuteOfDay, in: container, debugDescription: "Minute of day couldn't be converted to Int")
        }
        minuteOfDay = minuteAsInt

        let maxStr = try container.decode(String.self, forKey: .max)
        guard let maxAsFloat = Double(maxStr) else {
            throw DecodingError.dataCorruptedError(forKey: .max, in: container, debugDescription: "Max couldn't be converted toDouble")
        }
        max = maxAsFloat

        let avgStr = try container.decode(String.self, forKey: .avg)
        guard let avgAsFloat = Double(avgStr) else {
            throw DecodingError.dataCorruptedError(forKey: .avg, in: container, debugDescription: "Avg couldn't be converted toDouble")
        }
        avg = avgAsFloat

        let minStr = try container.decode(String.self, forKey: .min)
        guard let minAsFloat = Double(minStr) else {
            throw DecodingError.dataCorruptedError(forKey: .min, in: container, debugDescription: "Min couldn't be converted toDouble")
        }
        min = minAsFloat

        measureName = try container.decode(String.self, forKey: .measureName)
    }
}

//
//  Response.swift
//  EthGasTracker
//
//  Created by Tem on 10/21/24.
//


import Foundation

struct AveragesResponse: Codable {
    let averages: [String: AverageEntry]
}

struct AverageEntry: Codable {
    let avg: Double
    let deviation: Double
    let max: Double
    let measureName: String
    let min: Double
    let minuteOfDay: Int
    let minuteOfDayUTC: Int
    let p25: Double
    let p5: Double
    let p50: Double
    let p75: Double
    let p95: Double

    enum CodingKeys: String, CodingKey {
        case avg
        case deviation
        case max
        case measureName = "measure_name"
        case min
        case minuteOfDayUTC = "minute_of_day"
        case p25
        case p5
        case p50
        case p75
        case p95
    }

    // Custom decoding to handle both String and Double
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        avg = try AverageEntry.decodeAsDouble(container, forKey: .avg)
        deviation = try AverageEntry.decodeAsDouble(container, forKey: .deviation)
        max = try AverageEntry.decodeAsDouble(container, forKey: .max)
        min = try AverageEntry.decodeAsDouble(container, forKey: .min)
        p25 = try AverageEntry.decodeAsDouble(container, forKey: .p25)
        p5 = try AverageEntry.decodeAsDouble(container, forKey: .p5)
        p50 = try AverageEntry.decodeAsDouble(container, forKey: .p50)
        p75 = try AverageEntry.decodeAsDouble(container, forKey: .p75)
        p95 = try AverageEntry.decodeAsDouble(container, forKey: .p95)

        minuteOfDayUTC = try AverageEntry.decodeAsInt(container, forKey: .minuteOfDayUTC)
        minuteOfDay = localizeMinuteOfDay(minuteOfDayUTC)
        print("minuteOfDay: \(minuteOfDay) - minuteOfDayUTC: \(minuteOfDayUTC)")
        measureName = try container.decode(String.self, forKey: .measureName)
    }

    // Helper function to decode either a Double or String and convert it to Double
    static func decodeAsDouble(_ container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Double {
        if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return doubleValue
        }
        if let stringValue = try? container.decode(String.self, forKey: key), let doubleFromString = Double(stringValue) {
            return doubleFromString
        }
        throw DecodingError.typeMismatch(Double.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected to decode Double or String but failed"))
    }
    
    static func decodeAsInt(_ container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Int {
        if let intValue = try? container.decode(Int.self, forKey: key) {
            return intValue
        }
        if let stringValue = try? container.decode(String.self, forKey: key), let intFromString = Int(stringValue) {
            return intFromString
        }
        throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected to decode Int or String but failed"))
    }
}

func localizeMinuteOfDay(_ minute: Int) -> Int {
    let utcOffset = TimeZone.current.secondsFromGMT() / 60
    let localMinute = (minute + utcOffset) % 1440

    // If localMinute is negative, wrap it around to the end of the day
    return localMinute >= 0 ? localMinute : localMinute + 1440
}

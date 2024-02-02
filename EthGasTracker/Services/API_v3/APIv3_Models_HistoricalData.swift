//
//  APIv3_HistoricalDataModels.swift
//  EthGasTracker
//
//  Created by Tem on 12/15/23.
//

import Foundation

extension APIv3 {
    func getHistory(for range: HistoryRange, completion: @escaping(Result<GroupedHistoricalData, Error>) -> Void) {
        guard let url = getLink(for: range) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode([String: [HistoryRecord]].self, from: data)
                var groupedData = GroupedHistoricalData()

                if let records = response[range.rawValue] {
                    for record in records {
                        guard let jsonData = record.Values.data.data(using: .utf8) else {
                            print("Error: Unable to convert string to Data for record ID \(record.ID)")
                            continue
                        }
                        do {
                            let historicalData = try decoder.decode(HistoricalData.self, from: jsonData)
                            let key = HistoricalDataKey(timestamp: historicalData.date.timeIntervalSince1970, measureName: historicalData.measureName)
                            groupedData[key, default: []].append(historicalData)
                        } catch let error {
                            print("Error decoding HistoricalData for record ID \(record.ID): \(error)")
                            continue
                        }
                    }
                }

                completion(.success(groupedData))
            } catch let decodeError {
                completion(.failure(decodeError))
            }
        }
        task.resume()
    }
    
    func getLink(for range: HistoryRange) -> URL? {
        switch range {
        case .hour:
            return URL(string: Endpoints().historyHour)
        case .day:
            return URL(string: Endpoints().historyDay)
        case .week:
            return URL(string: Endpoints().historyWeek)
        case .month:
            return URL(string: Endpoints().historyMonth)
        }
    }
}

enum HistoryRange: String {
    case hour = "hour"
    case day = "day"
    case week = "week"
    case month = "month"
}

struct HistoryResponse: Codable {
    var data: [String: [HistoryRecord]]
}

struct HistoryRecord: Codable {
    let ID: String
    let Values: HourValues
}

struct HourValues: Codable {
    let data: String
    let timestamp: String
}

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

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSSSS" // Adjust this format to match your timestamp format
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}


struct HistoricalDataKey: Hashable {
    let timestamp: TimeInterval
    let measureName: String
}
typealias GroupedHistoricalData = [HistoricalDataKey: [HistoricalData]]

func getOrderedHistoricalData(from groupedData: GroupedHistoricalData) -> [HistoricalData] {
    let allData = groupedData.values.flatMap { $0 }
    return allData.sorted { $0.date < $1.date }
}

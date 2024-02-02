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

//enum HistoryRange: String {
//    case hour = "hour"
//    case day = "day"
//    case week = "week"
//    case month = "month"
//}
//
//struct HistoryResponse: Codable {
//    var data: [String: [HistoryRecord]]
//}
//
//struct HistoryRecord: Codable {
//    let ID: String
//    let Values: HourValues
//}
//
//struct HourValues: Codable {
//    let data: String
//    let timestamp: String
//}
//
//
//struct HistoricalDataKey: Hashable {
//    let timestamp: TimeInterval
//    let measureName: String
//}
//typealias GroupedHistoricalData = [HistoricalDataKey: [HistoricalData]]
//
//func getOrderedHistoricalData(from groupedData: GroupedHistoricalData) -> [HistoricalData] {
//    let allData = groupedData.values.flatMap { $0 }
//    return allData.sorted { $0.date < $1.date }
//}

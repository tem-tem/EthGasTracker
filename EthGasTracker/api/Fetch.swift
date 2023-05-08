//
//  Fetch.swift
//  EthGasTracker
//
//  Created by Tem on 3/11/23.
//

import Foundation

class MyAPI {
    func fetchStats(completion: @escaping (StatsResponse?, Error?) -> Void) {
        guard let url = URL(string: "http://65.109.175.89:8000/stats") else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode(StatsResponse.self, from: data)
                completion(results, nil)
            } catch let error {
                completion(nil, error)
            }
        }

        task.resume()
    }
    
    func fetchGasList(completion: @escaping (GasListServerResponse?, Error?) -> Void) {
        guard let url = URL(string: "http://65.109.175.89:8000/gas_list") else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode(GasListServerResponse.self, from: data)
                completion(results, nil)
            } catch let error {
                completion(nil, error)
            }
        }

        task.resume()

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if task.state == .running {
                task.cancel()
                completion(nil, NSError(domain: "Timeout", code: 0, userInfo: nil))
            }
        }
    }
}


struct GasData: Codable, Identifiable {
    let LastBlock: String
    let SafeGasPrice: String
    let ProposeGasPrice: String
    let FastGasPrice: String
    let suggestBaseFee: String
    let gasUsedRatio: String
    let timestamp: Int
    
    var id: Int {
        return timestamp
    }
}

struct EthData: Decodable {
    let ethbtc: String
    let ethbtc_timestamp: String
    let ethusd: String
    let ethusd_timestamp: String
}

extension GasData {
    static func placeholder() -> GasData {
        GasData(LastBlock: "...", SafeGasPrice: "...", ProposeGasPrice: "...", FastGasPrice: "...", suggestBaseFee: "...", gasUsedRatio: "...", timestamp: 0)
//        GasData(LastBlock: "...", SafeGasPrice: "...", ProposeGasPrice: "...", FastGasPrice: "...", suggestBaseFee: "...", gasUsedRatio: "...")
    }
}


struct ServerResponse: Decodable {
    let ethPrice: EthData?
    let gasData: GasData?
}

struct GasListServerResponse: Decodable {
    let gas_list: [GasData]?
}

let gasListKey = "GasList" // Key for storing the gasDataList in UserDefaults

class GasListLoader {
    func loadGasDataListFromUserDefaults() -> [GasData] {
        if let data = UserDefaults.standard.data(forKey: gasListKey),
           let decodedGasList = try? JSONDecoder().decode([GasData].self, from: data) {
            return decodedGasList
        }
        return []
    }
}

struct Stat: Codable {
    let average_gas_price: Double
    let timestamp_utc: String
}

struct StatsResponse: Codable {
    let stats: [Stat]
}

let statsKey = "StatsList" 

class StatsLoader {
    func loadStatsFromUserDefaults() -> [Stat] {
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decodedGasList = try? JSONDecoder().decode([Stat].self, from: data) {
            return decodedGasList
        }
        return []
    }
}

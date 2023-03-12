//
//  Fetch.swift
//  EthGasTracker
//
//  Created by Tem on 3/11/23.
//

import Foundation

func fetchGas(completion: @escaping (GasResponse?, Error?) -> Void) {
    guard let url = URL(string: "http://65.109.175.89:8000/") else {
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
            let results = try decoder.decode(GasResponse.self, from: data)
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


struct GasData: Decodable {
    let LastBlock: String
    let SafeGasPrice: String
    let ProposeGasPrice: String
    let FastGasPrice: String
    let suggestBaseFee: String
    let gasUsedRatio: String
}

struct GasResponse: Decodable {
    let status: String
    let message: String
    let result: GasData?
}

extension GasData {
    static func placeholder() -> GasData {
        GasData(LastBlock: "...", SafeGasPrice: "...", ProposeGasPrice: "...", FastGasPrice: "...", suggestBaseFee: "...", gasUsedRatio: "...")
    }
}

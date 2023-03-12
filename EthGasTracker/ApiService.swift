//
//  ApiService.swift
//  EthGasTracker
//
//  Created by Tem on 3/10/23.
//

import Foundation


final class ApiService {
    static let shared = ApiService()
    
    private let baseURL: String = "http://65.109.175.89:8000/"
    // A generic helper function to fetch some Decodable T from a given URL
    private func fetch<T: Decodable>() async throws -> T {
        let urlString = baseURL
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // The second return value is a URLResponse, that you can use to check the server's response to your request.
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(T.self, from: data)
        
        return result
    }
    
    func getGas() async throws -> GasData {
        let gas: GasResponse = try await fetch()
        print("gas response", gas)
        return gas.result
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
    let result: GasData
}

extension GasData {
    static func placeholder() -> GasData {
        GasData(LastBlock: "...", SafeGasPrice: "...", ProposeGasPrice: "...", FastGasPrice: "...", suggestBaseFee: "...", gasUsedRatio: "...")
    }
}

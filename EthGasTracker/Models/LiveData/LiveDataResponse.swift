//
//  ApiResponse.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

struct LiveDataResponse: Codable {
    let actions: [String: Action]
    let defaultActions: [String: Action]
    let currentStats: CurrentStats
    let indexes: Indexes
    let currencyRate: String?
}

struct Action: Codable {
    let name: String
    let groupName: String
    let key: String
    let limit: Double
}

struct Indexes: Codable {
    let eth_price: [ResponseIndex]
    let gas: [ResponseIndex]
    
    private var gasTimestamps: Set<String> {
        Set(gas.map { $0.ID.split(separator: "-").first.map(String.init) ?? "" })
    }
    private var ethTimestamps: Set<String> {
        Set(eth_price.map { $0.ID.split(separator: "-").first.map(String.init) ?? "" })
    }
    
    var commonTimestamps: Set<String> {
        gasTimestamps.intersection(ethTimestamps)
    }
}

struct ResponseIndex: Codable {
    let ID: String
    let Values: [String: String]
}

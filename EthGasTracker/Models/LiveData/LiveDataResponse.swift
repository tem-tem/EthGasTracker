//
//  ApiResponse.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

struct ApiResponse_GetLatest: Codable {
    let actions: [String: Action]
    let defaultActions: [String: Action]
    let currentStats: CurrentStats
    let indexes: Indexes
    let currencyRate: String?
}

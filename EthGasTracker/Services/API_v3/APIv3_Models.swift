//
//  API_v2_Structs.swift
//  EthGasTracker
//
//  Created by Tem on 11/5/23.
//

import Foundation

struct APIv3_GetLatestResponse: Codable {
    let actions: [String: Action]
    let currentStats: CurrentStats
    let defaultActions: [String: Action]
    let indexes: Indexes
    let currencyRate: String?
}

// SHARED


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

struct Metadata {
    let name: String
    let groupName: String
    let key: String
    let limit: Int64
}

struct NormalFast {
    var normal: Float
    var fast: Float
}

struct FluctuationRange {
    var minNormal: Float
    var maxNormal: Float
    var rangeNormal: Float

    var minFast: Float
    var maxFast: Float
    var rangeFast: Float
}

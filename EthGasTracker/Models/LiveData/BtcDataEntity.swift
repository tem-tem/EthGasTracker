//
//  BtcDataEntity.swift
//  EthGasTracker
//
//  Created by Tem on 2/19/24.
//

import Foundation

struct BtcDataEntity: Codable {
    let price: Double
    let rate: Int
    let histogram: [Int: [Int]]
}

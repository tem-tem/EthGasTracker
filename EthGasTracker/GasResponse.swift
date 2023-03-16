//
//  GasResponse.swift
//  EthGasTracker
//
//  Created by Tem on 3/15/23.
//

import Foundation

struct GasResponse: Codable {
    var FastGasPrice: String?
    var ProposeGasPrice: String?
    var SafeGasPrice: String?
    var suggestBaseFee: String?
    var gasUsedRatio: String?
    var LastBlock: String?
    var message: String?
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    
    init() {
        FastGasPrice = nil
        ProposeGasPrice = nil
        SafeGasPrice = nil
        suggestBaseFee = nil
        gasUsedRatio = nil
        LastBlock = nil
        message = nil
    }
}

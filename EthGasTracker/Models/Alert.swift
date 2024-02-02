//
//  Alerts.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import Foundation

struct Alert: Codable, Identifiable { // Conform to both Encodable and Decodable
    let id: String? // ID property is now optional
    let deviceId: String
    let mutePeriod: Int
    let conditions: [Condition]
    var disabled: Bool?
    let legacyGas: Bool?
    let confirmationPeriod: Int
    let disableAfterAlerts: Int?
    let disabledHours: [Int]
    
    
    struct Condition: Codable { // Conform to both Encodable and Decodable
        let comparison: Comparison
        let value: Int
        
        enum Comparison: String, Codable, CaseIterable {
            case greater_than
            case greater_than_or_equal
            case less_than
            case less_than_or_equal
        }
    }
    
    func isPremium() -> Bool {
        return confirmationPeriod > 0 || (disableAfterAlerts ?? 0) > 0 || disabledHours.count > 1
    }
}

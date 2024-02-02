//
//  GasLevel.swift
//  EthGasTracker
//
//  Created by Tem on 1/9/24.
//

import Foundation
import SwiftUI

struct GasLevel {
    let currentStats: CurrentStats
    let currentGas:Double
    
    init(currentStats: CurrentStats, currentGas:Double) {
        self.currentStats = currentStats
        self.currentGas = currentGas
    }

    var level: Int {
        // Calculate the level based on the percentiles
        switch currentGas {
        case ...currentStats.min:
            return 0
        case currentStats.min..<currentStats.p5:
            return 1
        case currentStats.p5..<currentStats.p25:
            return 2
        case currentStats.p25..<currentStats.p75:
            // Calculate a level between 2 and 8 based on where currentGas falls within the interquartile range
            let interquartileRange = currentStats.p75 - currentStats.p25
            let interquartilePosition = currentGas - currentStats.p25
            let interquartileRatio = interquartilePosition / interquartileRange
            return 3 + Int(interquartileRatio * 4) // Scale it to a range of 3-7
        case currentStats.p75...currentStats.p95:
            return 8
        case currentStats.p95...currentStats.max:
            return 9
        case currentStats.max...:
            return 10
        default:
            return -1 // Represents an error or unknown level
        }
    }
    
    var color: Color {
        return GasLevel.getColor(for: self.level)
    }
    
    var label: String {
        return GasLevel.getLabel(for: self.level)
    }

    static func getColor(for level: Int) -> Color {
        switch level {
        case 0...2:
            return Color(.systemGreen)
        case 3...8:
            return Color(.systemBlue)
        case 9:
            return Color(.systemOrange)
        case 10:
            return Color(.systemRed)
        default:
            return Color(.systemGray)
        }
    }

    static func getLabel(for level: Int) -> String {
        switch level {
        case 0:
            return "MIN"
        case 1:
            return "VERY LOW"
        case 2:
            return "LOW"
        case 3...7:
            return "NORMAL"
        case 8:
            return "HIGH"
        case 9:
            return "PEAKING"
        case 10:
            return "SURGE"
        default:
            return "Unknown"
        }
    }
    
    static func getDescription(for level: Int) -> String {
        switch level {
        case 0:
            return "Below the typical minimum."
        case 1:
            return "Between the typical minimum and lower 5%."
        case 2:
            return "Within the 5th to 25th percentile range."
        case 3...7:
            return "Within the 25th to 75th percentile, reflecting average gas prices."
        case 8:
            return "Above average but within the 75th to 95th percentile."
        case 9:
            return "Between the 95th percentile and near peak levels."
        case 10:
            return "Surpassing the typical maximum average."
        default:
            return "Status: Unknown"
        }
    }
}

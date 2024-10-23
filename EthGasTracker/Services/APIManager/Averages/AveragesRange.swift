//
//  AveragesRange.swift
//  EthGasTracker
//
//  Created by Tem on 10/21/24.
//

import Foundation


enum AveragesRange: Int, CaseIterable {
    case week = 7
    case month = 30
    case threeMonths = 90
    case sixMonths = 180
    case year = 365

    var displayName: String {
        switch self {
        case .week: return "7D"
        case .month: return "1M"
        case .threeMonths: return "3M"
        case .sixMonths: return "6M"
        case .year: return "1Y"
        }
    }
}

// Enum for AveragesWeekday, also conforms to CaseIterable for use in Picker
enum AveragesWeekday: Int, CaseIterable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7

    var displayName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }
}

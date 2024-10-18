//
//  ChartTypes.swift
//  EthGasTracker
//
//  Created by Tem on 10/10/24.
//
import Foundation

enum ChartTypes: String, CaseIterable {
    case month = "1M"
    case week = "7D"
    case day = "24H"
    case hour = "1H"
    case live = "LIVE"
}

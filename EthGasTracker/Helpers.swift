//
//  Helpers.swift
//  EthGasTracker
//
//  Created by Tem on 5/14/23.
//

import Foundation
import SwiftUI

func colorForValue(value: Double, min minValue: Double, max maxValue: Double) -> Color {
    guard minValue <= value, value <= maxValue else {
        print("Value must be between min and max.")
        return Color("avg")
    }
    
    let colors = [
        Color(hex: "F94144"),
        Color(hex: "F3722C"),
        Color(hex: "F8961E"),
        Color(hex: "F9C74F"),
        Color(hex: "90BE6D"),
        Color(hex: "43AA8B")
    ]
    
    let range = maxValue - minValue
    let step = range / Double(colors.count)
    let index = (value - minValue) / step
    
    return colors.reversed()[min(Int(index), 5)]
}

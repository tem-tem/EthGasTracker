//
//  GasScale.swift
//  EthGasTracker
//
//  Created by Tem on 9/5/23.
//

import SwiftUI

struct GasScale: View {
//    let lastGasPrice: Float?
    @Binding var selectedPrice: Float?
    
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var activeSquares: Int = 0
    
    var stats: StatsEntries {
        return appDelegate.stats
    }
    
    let hour = min(max(Calendar.current.component(.hour, from: Date()), 0), 23)

    var hourStatEntry: StatsEntries.Entry {
        guard stats.statsGroupedByHourNormal.count >= (hour-1), stats.statsGroupedByHourNormal.count > 0 else {
            return StatsEntries.Entry(minuteOfDay: 0, max: 0.0, avg: 0, min: 0, measureName: "")
        }
        return stats.statsGroupedByHourNormal[hour]
    }
    
    var lastGasPrice: Float? {
        return appDelegate.gasIndexEntries.last?.normal
//        return isFastMain ? lastEntry?.fast : lastEntry?.normal
    }
    
    // Function to determine the number of active squares based on the gas price or another appropriate measure
    private func updateActiveSquares(value: Float) {
        // Here, you need to implement your logic to set the number of active squares
        // This is an example, assuming you want to activate squares based on 'lastGasPrice'.
        let priceRange = stats.avgMax - stats.avgMin
        let priceStep = priceRange / 6 // since there are 5 squares

        // Determine the number of squares to activate
        activeSquares = Int((value - stats.avgMin) / priceStep)

        // Ensure we don't go out of bounds
        activeSquares = min(max(activeSquares, 0), 6)
    }
    
    let colors = [
        Color.accentColor,
        Color.accentColor,
        Color(.systemOrange),
        Color(.systemOrange),
        Color(.systemRed),
        Color(.systemRed),
    ]
    
    var body: some View {
        HStack (alignment: .center, spacing: 5) {
            ForEach(0..<6) { index in
                Rectangle()
//                    .overlay
                    .fill(index < activeSquares ? colors[index] : Color.primary.opacity(0.1))
                    .frame(width: 10, height: 10)
                    .cornerRadius(10)
                    .shadow(color: colors[index], radius: index < activeSquares ? 4 : 0, x: 0, y: 0)
//                    .frame(width: 5 * CGFloat(abs(index - 5)), height: 10) // or whatever size you prefer
//                    .background(index < activeSquares ? colors[index] : Color.primary.opacity(0.1))
//                    .opacity(index < activeSquares ? 1 : 0.2) // active squares are white
//                    .border(Color.primary.opacity(0.3), width: /* border width */ 1) // optional border
            }
        }
        .onAppear {
            updateActiveSquares(value: lastGasPrice ?? selectedPrice ?? 0)
        }
        .onChange(of: lastGasPrice) { newValue in
            if let value = newValue {
                updateActiveSquares(value: value)
            }
        }
        .onChange(of: selectedPrice) { selected in
            if let value = selected {
                updateActiveSquares(value: value)
            } else {
                updateActiveSquares(value: lastGasPrice ?? 0)
            }
        }
        // ... Any other modifiers or logic
    }
}

struct GasScale_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            GasScale(selectedPrice: .constant(12.2))
        }
    }
}

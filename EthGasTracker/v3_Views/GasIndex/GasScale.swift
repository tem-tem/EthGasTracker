//
//  GasScale.swift
//  EthGasTracker
//
//  Created by Tem on 9/5/23.
//

import SwiftUI

struct GasScale: View {
    @AppStorage(SettingsKeys().hapticFeedbackEnabled) private var haptic = true
    let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @EnvironmentObject var appDelegate: AppDelegate
    
    let gradient = Gradient(colors: [.accentColor, Color(.systemRed)])
    
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
    
    var lastGasPrice: Float {
        guard let lastEntry = appDelegate.gasIndexEntries.last else {
            return 0
        }
        return isFastMain ? lastEntry.fast : lastEntry.normal
    }
    
    var body: some View {
        Gauge(value: lastGasPrice, in: stats.avgMin...stats.avgMax) {
            
        }
        .gaugeStyle(.accessoryLinear)
        .tint(gradient)
    }
}

struct GasScale_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            GasScale()
        }
    }
}

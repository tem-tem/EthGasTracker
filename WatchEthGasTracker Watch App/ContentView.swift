//
//  ContentView.swift
//  WatchEthGasTracker Watch App
//
//  Created by Tem on 2/16/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    
    var gas: Double {
        liveDataVM.gasLevel.currentGas
    }
    
    var color: Color {
        liveDataVM.gasLevel.color
    }
    
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(liveDataVM.timestamp / 1000))
    }
    
    var customDateFormat: String {
        let currentDate = Date()

        if date.isSameDay(as: currentDate) {
            return "HH:mm:ss"
        } else if date.isSameMonth(as: currentDate) {
            return "dd HH:mm:ss"
        } else if date.isSameYear(as: currentDate) {
            return "MMM dd HH:mm:ss"
        } else {
            return "yyyy MMM dd HH:mm:ss"
        }
    }
    var body: some View {
        VStack {
            Spacer()
            HStack {
                FetchingStatusBar()
                Spacer()
                Text(date, formatter: DateFormatter.customDateFormatter(withFormat: customDateFormat))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack {
                
            }
            HStack {
                VStack {
                    Text(String(format: "%.f", round(gas)))
                        .lineLimit(1)
                        .font(.system(size: 180, weight: .semibold, design: .default))
                        .minimumScaleFactor(0.5)
                    Text("\(liveDataVM.gasLevel.label)")
                }
                .foregroundStyle(color)
            }
            
            GasScaleDots(gasLevel: liveDataVM.gasLevel)
        }
        .padding()
    }
}

#Preview {
    WatchPreviewWrapper {
        ContentView()
    }
}

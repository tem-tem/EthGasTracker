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
    
    var rate: Double {
        Double(liveDataVM.btcDataEntity.rate)
    }
    var body: some View {
        TabView {
            VStack {
                Text(String(format: "%.f", round(gas)))
                    .lineLimit(1)
                    .font(.system(size: 100, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.5)
                Text("gwei")
                    .font(.system(.caption, design: .rounded))
            }
            .foregroundStyle(color)
            
            VStack {
                Spacer()
                Text(String(format: "%.f", round(rate)))
                    .foregroundStyle(
                        .orange
                            .shadow(.inner(color: .red.opacity(0.3), radius: 10, x: 0, y: 0))
                            .shadow(.inner(color: .white.opacity(0.7), radius: 5, x: 0, y: 0))
                    )
                    .lineLimit(1)
                    .font(.system(size: 100, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.5)
                HStack {
                    Spacer()
                    Text("sat/vB")
                        .font(.system(.caption, design: .rounded))
                    Spacer()
                }
                Spacer()
            }
//            .background(Color(.orange))
            
            VStack {
                VStack {
                    Text(String(format: "%.f", round(gas)))
                        .lineLimit(1)
                        .font(.system(size: 50, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.5)
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(liveDataVM.gasLevel.label)")
                                .font(.system(.caption, design: .rounded))
                                .frame(height: 10)
                            GasScaleDots(gasLevel: liveDataVM.gasLevel)
                                .frame(height: 10)
                        }
                        Spacer()
                    }
                    LiveGasChartWatch()
                    
                }
                .foregroundStyle(color)
            }
            
        }
        .tabViewStyle(.carousel)
    }
}

#Preview {
    WatchPreviewWrapper {
        ContentView()
    }
}

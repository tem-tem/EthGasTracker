//
//  GasIndexFocus.swift
//  EthGasTracker
//
//  Created by Tem on 8/20/23.
//

import SwiftUI

struct GasIndexFocus: View {
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @EnvironmentObject var appDelegate: AppDelegate
    
    @Binding var selectedDate: Date?
    @Binding var selectedPrice: Float?
    
    var lastGasPrice: Float? {
        let lastEntry = appDelegate.gasIndexEntries.last
        return isFastMain ? lastEntry?.fast : lastEntry?.normal
    }

    var body: some View {
        VStack {
            Text(String(format: "%.f", selectedPrice ?? lastGasPrice ?? 0))
                .font(.system(size: 100, weight: .thin))
                .padding(.top, -5)
            
            if let last = lastGasPrice,
               let selected = selectedPrice,
               let diff = last - selected,
               diff != 0
            {
                HStack {
                    if (diff > 0) {
                        Image(systemName: "arrow.down")
                    } else {
                        Image(systemName: "arrow.up")
                    }
                    Text(String(format: "%.1f", abs(diff)))
                }
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundStyle(diff > 0 ? Color.accentColor : Color(.systemRed))
                
            } else {
                HStack {
                    Image(systemName: "arrow.up")
                    Text(String(format: "%.1f", 0))
                }
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .opacity(0)
                
            }
        }
    }
}

struct GasIndexFocus_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            GasIndexFocus(selectedDate: .constant(Date()), selectedPrice: .constant(23))
        }
    }
}

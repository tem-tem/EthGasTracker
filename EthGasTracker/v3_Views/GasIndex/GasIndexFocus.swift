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
                .font(.system(size: 80, weight: selectedPrice != nil ? .thin : .heavy, design: .rounded))
                .padding(.top, -5)
                .padding(.bottom, -10)
                .foregroundStyle(
                    selectedPrice != nil ?
                        Color.primary.gradient
                        .shadow(.inner(color: Color("lowLight"), radius: 0, x: 0, y: 0)) :
                        Color.accentColor.gradient
                        .shadow(.inner(color: Color("lowLight"), radius: 4, x: 0, y: 0))
                )
            
            
            if let last = lastGasPrice,
               let selected = selectedPrice,
               let diff = last - selected
            {
                HStack {
                    if (diff > 0) {
                        Image(systemName: "arrow.down")
                    } else {
                        Image(systemName: "arrow.up")
                    }
                    Text(String(format: "%.1f", abs(diff)))
                }
                .opacity(diff == 0 ? 0 : 1)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundStyle(diff > 0 ? Color.accentColor : Color(.systemRed))
                
            } else {
                ZStack(alignment: .center) {
                    HStack {
                        Image(systemName: "arrow.up")
                        Text(String(format: "%.1f", 0))
                    }
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .opacity(0)
                    GasScale()
                        .frame(width: 100)
                }
                
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

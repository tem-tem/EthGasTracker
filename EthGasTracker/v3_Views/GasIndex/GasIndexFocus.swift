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
//        return 9874
        let lastEntry = appDelegate.gasIndexEntries.last
        return isFastMain ? lastEntry?.fast : lastEntry?.normal
    }
    
    var fluctuationRange: FluctuationRange? {
        return appDelegate.gas.calculateFluctuationRange()
    }

    var body: some View {
        HStack {
            Spacer()
//            VStack {
//                Text(String(format: "%.f", fluctuationRange?.minNormal ?? 0))
//                    .font(.system(size: 30, weight: .thin, design: .monospaced))
//                Text("MIN").font(.caption)
//            }.opacity(selectedPrice != nil ? 0.4 : 1)
//            Spacer()
            VStack(spacing: 15) {
                Text(String(format: "%.f", selectedPrice ?? lastGasPrice ?? 0))
                    .font(.system(size: 60, weight: selectedPrice != nil ? .thin : .bold, design: .monospaced))
                    .padding(.top, -5)
                    .padding(.bottom, -5)
    //            Divider()
                GasScale(selectedPrice: $selectedPrice)
                
    //            if let last = lastGasPrice,
    //               let selected = selectedPrice,
    //               let diff = last - selected
    //            {
    //                HStack {
    //                    if (diff > 0) {
    //                        Image(systemName: "arrow.down")
    //                    } else {
    //                        Image(systemName: "arrow.up")
    //                    }
    //                    Text(String(format: "%.1f", abs(diff)))
    //                }
    //                .opacity(diff == 0 ? 0 : 1)
    //                .font(.system(size: 24, weight: .bold, design: .monospaced))
    //                .foregroundStyle(diff > 0 ? Color.accentColor : Color(.systemRed))
    //
    //            } else {
    //                ZStack(alignment: .center) {
    //                    HStack {
    //                        Image(systemName: "arrow.up")
    //                        Text(String(format: "%.1f", 0))
    //                    }
    //                    .font(.system(size: 24, weight: .bold, design: .monospaced))
    //                    .opacity(0)
    //                    GasScale()
    //                        .frame(width: 100)
    //                }
    //
    //            }
            
            }
            Spacer()
//            VStack {
//                Text(String(format: "%.f", fluctuationRange?.maxNormal ?? 0))
//                    .font(.system(size: 30, weight: .thin, design: .monospaced))
//                Text("MAX").font(.caption)
//            }.opacity(selectedPrice != nil ? 0.4 : 1)
//            Spacer()
        }
    }
}

struct GasIndexFocus_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            GasIndexFocus(selectedDate: .constant(nil), selectedPrice: .constant(nil))
        }
    }
}

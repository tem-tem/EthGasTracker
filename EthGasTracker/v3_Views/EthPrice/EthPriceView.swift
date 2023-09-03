//
//  EthPriceView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

struct EthPriceView: View {
    @Binding var selectedKey: String?
    @Binding var selectedDate: Date?
    @AppStorage("isStale") var isStale = false
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        ZStack {
            HStack {
                TimestampView(selectedDate: $selectedDate)
                Spacer()
                
                if (selectedKey == nil) {
                    Text("ETH").font(.caption)
                    Text(
                        ((appDelegate.ethPrice.lastEntry()?.value ?? PriceData(price: 0)).price),
                        format: .currency(code: "usd")
                    ).bold()
                } else {
                    if let lastEntryValue = (appDelegate.ethPrice.lastEntry()?.value ?? PriceData(price: 0)).price,
                       let selectedEntryValue = appDelegate.ethPrice.entries[selectedKey!]?.price,
                       let diff = lastEntryValue - selectedEntryValue
                    {
                        HStack {
                            if (diff > 0) {
                                Image(systemName: "arrow.down")
                            } else {
                                Image(systemName: "arrow.up")
                            }
                            Text(abs(diff), format: .currency(code: "usd"))
                        }
                        .font(.system(.caption, design: .monospaced))
                        .opacity(0.5)
//                        .foregroundStyle(diff > 0 ? Color(.systemGreen) : Color(.systemRed))
                        
                        Text("ETH").font(.caption)
                        Text(
                            (selectedEntryValue),
                            format: .currency(code: "usd")
                        ).bold()
                    }
                }
            }
            .font(.system(.caption, design: .monospaced))
//            HStack {
//                EthPriceChart(priceEntity: appDelegate.ethPrice)
//                    .padding(.leading, 150)
//                    .padding(.vertical, 3)
//            }
//            .opacity(isStale ? 0.6 : 1)
//            .saturation(isStale ? 0 : 1)
//            .animation(.easeInOut(duration: isStale ? 0.5 : 0.1), value: isStale)
        }
//        .frame(height: 30)
        .font(.caption)
    }
}

//struct EthPriceView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewWrapper {
//            EthPriceView()
//        }
//    }
//}

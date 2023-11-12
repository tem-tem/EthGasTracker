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
    
    var lastValue: Float {
        return (appDelegate.ethPrice.lastEntry()?.value ?? PriceData(price: 0)).price
    }
    
    var body: some View {
        ZStack {
            HStack {
                TimestampView(selectedDate: $selectedDate)
                Spacer()
                
                if let key = selectedKey,
                   let selectedEntry = appDelegate.ethPrice.entries[key]
                {
                    let selectedValue = selectedEntry.price
                    DiffValueView(
                        baseValue: (appDelegate.ethPrice.lastEntry()?.value ?? PriceData(price: 0)).price,
                        targetValue: selectedValue
                    )
                    Text("ETH")
                    Text(String(format: "$%.2f", selectedValue)).bold()
                } else {
                    Text("ETH")
                    Text(String(format: "$%.2f", lastValue)).bold()
                    
                }
            }
            .font(.system(.caption, design: .monospaced))
            .textCase(.uppercase)
//            .foregroundColor(appDelegate.gasLevel.color)
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

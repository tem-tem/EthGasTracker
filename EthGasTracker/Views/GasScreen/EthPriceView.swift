//
//  EthPriceView.swift
//  EthGasTracker
//
//  Created by Tem on 1/19/24.
//

import SwiftUI

struct EthPriceView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    var value: Double
    var price: Double {
        if let index = activeSelectionVM.index {
            let price = liveDataVM.ethPriceEntity.entries[index].price
            return price
        } else if let historicalData = activeSelectionVM.historicalData {
            return historicalData.price
        }
        return value
    }
    var body: some View {
        HStack {
            Text("ETH")
                .foregroundStyle(.secondary)
            PriceNumberView(value: price)
        }
        .font(.system(.caption, design: .monospaced))
    }
}

#Preview {
    EthPriceView(value: 2345.5432)
}

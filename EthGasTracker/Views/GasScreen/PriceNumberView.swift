//
//  PriceNumberView.swift
//  EthGasTracker
//
//  Created by Tem on 1/19/24.
//

import SwiftUI

struct PriceNumberView: View {
    let value: Double
    @AppStorage("currency", store: UserDefaults(suiteName: "group.TA.EthGas")) var currency: String = "USD"
    var currencyCode: String {
        return getSymbol(forCurrencyCode: currency) ?? currency
    }
    
    var body: some View {
        Text(
            String(
                format: "\(currencyCode.count == 1 ? currencyCode : "")%.2f",
                value
            )
        )
    }
}

#Preview {
    PriceNumberView(value: 123.456)
}

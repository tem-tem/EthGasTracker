//
//  EthPriceView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

struct EthPriceView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        Text("ETH ").bold() +
        Text(appDelegate.ethPrice, format: .currency(code: "usd"))
    }
}

struct EthPriceView_Previews: PreviewProvider {
    static var previews: some View {
        EthPriceView()
    }
}

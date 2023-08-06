//
//  LegacyGasPriceView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

struct LegacyGasPriceView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Legacy").bold()
            HStack {
                Text("Low")
                Spacer()
                Text("Average")
                Spacer()
                Text("High")
            }.font(.caption)
            HStack {
                Text(appDelegate.legacyGas.low, format: .number)
                Spacer()
                Text(appDelegate.legacyGas.avg, format: .number)
                Spacer()
                Text(appDelegate.legacyGas.high, format: .number)
            }.bold().font(.title)
        }
    }
}

struct LegacyGasPriceView_Previews: PreviewProvider {
    static var previews: some View {
        LegacyGasPriceView()
    }
}

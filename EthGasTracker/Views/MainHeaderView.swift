//
//  MainHeaderView.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import SwiftUI

struct MainHeaderView: View {
    let showGas: Bool
    @EnvironmentObject var liveDataVM: LiveDataVM
    
    var body: some View {
        VStack {
            HStack {
                if (showGas) {
                    Text(String(format: "%.f", liveDataVM.gasLevel.currentGas))
                        .font(.system(.caption, design: .monospaced))
                    Text("gwei")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                EthPriceView(value: liveDataVM.ethPriceEntity.entries.last?.price ?? 0.0)
            }
            .padding(.horizontal)
            Divider()
                .padding(.horizontal)
        }
    }
}

#Preview {
    MainHeaderView(showGas: true)
}

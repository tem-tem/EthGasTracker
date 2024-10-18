//
//  MainHeaderView.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import SwiftUI

struct MainHeaderView: View {
    let showGas: Bool
    let showBtc: Bool
    let showEth: Bool
    @EnvironmentObject var liveDataVM: LiveDataVM
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    HStack {
                        Text("BTC")
                            .foregroundStyle(.secondary)
                        PriceNumberView(value: liveDataVM.btcDataEntity.price)
                    }
                    .font(.system(.caption, design: .monospaced))
                    .opacity(showBtc ? 1 : 0)
                    Spacer()
                }
                .padding(.horizontal)
                HStack {
                    HStack {
                        Text(String(format: "%.f", liveDataVM.gasLevel.currentGas))
                            .font(.system(.caption, design: .monospaced))
                        Text("gwei")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }.opacity(showGas ? 1 : 0)
                    Spacer()
                    EthPriceView(value: liveDataVM.ethPrice)
                        .opacity(showEth ? 1 : 0)
                }
                .padding(.horizontal)
            }
            Divider()
        }
    }
}

#Preview {
    PreviewWrapper {
        MainHeaderView(showGas: true, showBtc: true, showEth: true)
    }
}

//
//  BtcCardView.swift
//  EthGasTracker
//
//  Created by Tem on 2/20/24.
//

import SwiftUI

struct BtcCardView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    
    var rate: Double {
        Double(liveDataVM.btcDataEntity.rate)
    }
    
    var segWit: Double {
        calculateTransactionCost(transactionSizeInVb: 140, feeRateInSatPerVb: Int(rate), bitcoinPriceInFiat: liveDataVM.btcDataEntity.price)
    }
    
    var p2pkh: Double {
        calculateTransactionCost(transactionSizeInVb: 226, feeRateInSatPerVb: Int(rate), bitcoinPriceInFiat: liveDataVM.btcDataEntity.price)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text("SegWit")
                    PriceNumberView(value: segWit)
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color(.systemOrange))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("P2PKH")
                    PriceNumberView(value: p2pkh)
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color(.systemOrange))
                }
            }.padding()
            .font(.caption)
            Divider()
            Spacer()
            HStack {
                Spacer()
                Text(String(format: "%.f", round(rate)))
                    .foregroundStyle(
                        .orange
                            .shadow(.inner(color: .red.opacity(0.3), radius: 20, x: 0, y: 0))
                            .shadow(.inner(color: .white.opacity(0.7), radius: 10, x: 0, y: 0))
                    )
                    .lineLimit(1)
                    .font(.system(size: 180, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.5)
                Spacer()
            }
            Text("sat/vB")
                .font(.caption)
//                .foregroundStyle(.white)
            Spacer()
            
        }
//        .overlay(
//            RoundedRectangle(cornerRadius: 20)
//                .stroke(Color(.systemOrange), lineWidth: 5)
//        )
        .background(Color("BG.L1"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

func calculateTransactionCost(transactionSizeInVb: Int, feeRateInSatPerVb: Int, bitcoinPriceInFiat: Double) -> Double {
    // Calculate the total transaction fee in satoshis
    let totalFeeInSatoshis = transactionSizeInVb * feeRateInSatPerVb
    
    // Convert satoshis to Bitcoin (1 Bitcoin = 100,000,000 satoshis)
    let totalFeeInBitcoin = Double(totalFeeInSatoshis) / 100_000_000
    
    // Convert the Bitcoin fee to fiat currency
    let totalFeeInFiat = totalFeeInBitcoin * bitcoinPriceInFiat
    
    return totalFeeInFiat
}

#Preview {
    PreviewWrapper {
        VStack {
            BtcCardView()
        }
        .ignoresSafeArea()
            .background(Color("BG.L0"))
            .padding(5)
    }
}

//
//  ActionXLView.swift
//  EthGasTracker
//
//  Created by Tem on 1/17/24.
//

import SwiftUI
let borderOpacity = 0.5

let dotW = 5.0
let dotH = 5.0
let dotOpacity = 0.25

struct ActionXLView: View {
    let name: String
    let groupName: String
    let value: Double
    let accentColor: Color
    let primaryColor: Color
    let secondaryColor: Color
    
    @AppStorage("currency", store: UserDefaults(suiteName: "group.TA.EthGas")) var currency: String = "USD"
    var currencyCode: String {
        return getSymbol(forCurrencyCode: currency) ?? currency
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            Text(
                String(
                    format: "\(currencyCode.count == 1 ? currencyCode : "")%.2f",
                    value
                )
            )
            .font(.system(.title3, design: .monospaced))
            .foregroundStyle(accentColor)
            .bold()
            .padding(.vertical)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(secondaryColor.opacity(borderOpacity))
            HStack {
                Spacer()
                Text("\(name)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(primaryColor)
                    .bold()
                Spacer()
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(secondaryColor.opacity(borderOpacity))
                Spacer()
                Text("\(groupName)")
//                    .font(.system(.caption, design: .monospaced))
//                    .opacity(0.75)
                    .font(.system(.caption2, design: .monospaced, weight: .thin))
                    .foregroundStyle(secondaryColor)
                Spacer()
            }.frame(height: 20)
        }
        .border(secondaryColor.opacity(borderOpacity), width: 1)
        .overlay {
            ZStack {
                VStack {
                    HStack {
                        Rectangle()
                            .frame(width: dotW, height: dotH)
                        Spacer()
                        Rectangle()
                            .frame(width: dotW, height: dotH)
                    }
                    Spacer()
                    HStack {
                        Rectangle()
                            .frame(width: dotW, height: dotH)
                        Spacer()
                        Rectangle()
                            .frame(width: dotW, height: dotH)
                    }
                }
//                VStack {
//                    HStack {
//                        Rectangle()
//                            .frame(width: dotH, height: dotW)
//                        Spacer()
//                        Rectangle()
//                            .frame(width: dotH, height: dotW)
//                    }
//                    Spacer()
//                    HStack {
//                        Rectangle()
//                            .frame(width: dotH, height: dotW)
//                        Spacer()
//                        Rectangle()
//                            .frame(width: dotH, height: dotW)
//                    }
//                }
            }
            .foregroundStyle(secondaryColor.opacity(borderOpacity))
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        HStack(spacing: 0) {
            ActionXLView(name: "Uniswap", groupName: "Native Bridges", value: 2.34, accentColor: .green, primaryColor: .primary, secondaryColor: .blue).padding(1)
            ActionXLView(name: "Uniswap", groupName: "DEX", value: 2.34, accentColor: .green, primaryColor: .primary, secondaryColor: .blue).padding(1)
        }
        HStack(spacing: 0) {
            ActionXLView(name: "Uniswap", groupName: "Native Bridges", value: 2.34, accentColor: .green, primaryColor: .primary, secondaryColor: .blue).padding(1)
            ActionXLView(name: "Uniswap", groupName: "DEX", value: 2.34, accentColor: .green, primaryColor: .primary, secondaryColor: .blue).padding(1)
        }
    }
}

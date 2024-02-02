//
//  SwiftUIView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

struct NormalFastView: View {
    var isGas = false
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    let normal:Double
    let fast:Double
    let currency: String?
    
    var mainValue:Double {
        isFastMain ? fast : normal
    }
    var subValue:Double {
        isFastMain ? normal : fast
    }
    
    var body: some View {
        VStack(alignment: isGas ? .leading : .center) {
//            Text(isFastMain ? "Fast" : "Normal").font(.caption)
            if (currency != nil) {
                Text(mainValue, format: .currency(code: currency ?? "usd"))
                    .font(.system(.title, design: .monospaced))
                    .bold()
                    .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                    .lineLimit(1)
//                    .foregroundStyle(
//                        Color.primary.gradient
//                            .shadow(.inner(color: Color(.white).opacity(1), radius: 2, x: 0, y: 0))
//                    )
//                    .shadow(color: Color(.systemBackground), radius: 5)
                    .padding(.bottom, -10)
                    .padding(.top, -10)
            } else {
                if (isGas) {
                    Text(String(format: "%.2f", mainValue))
                        .font(.system(size: 60, design: .rounded)).bold()
                        .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                        .lineLimit(1)
                        .foregroundStyle(
                            Color("avg").gradient
                                .shadow(.inner(color: Color("avgLight").opacity(1), radius: 4, x: 0, y: 0))
                        )
                        .shadow(color: Color(.systemBackground), radius: 5)
                        .padding(.bottom, -10)
                        .padding(.top, -10)
                } else {
                    Text(String(format: "%.2f", mainValue))
                        .bold().font(.title)
                }
            }
            
//            HStack() {
//                Text(isFastMain ? "Normal" : "Fast")
//                if (currency != nil) {
//                    Text(subValue, format: .currency(code: currency ?? "usd"))
//                } else {
//                    Text(String(format: "%.2f", subValue))
//                }
//            }.font(.caption)
        }
    }
}

struct NormalFastView_Previews: PreviewProvider {
    static var previews: some View {
        NormalFastView(isGas: true, normal: 1.0, fast: 2.0, currency: "usd")
    }
}

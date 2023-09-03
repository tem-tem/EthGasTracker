//
//  SwiftUIView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

struct GasPriceView: View {
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    var isExample = false
    var isMiniView = false
//    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @EnvironmentObject var appDelegate: AppDelegate
    var entries: [GasIndexEntity.ListEntry] {
        appDelegate.gasIndexEntries
    }
    var lastGas: (key: String, value: NormalFast)? {
        appDelegate.gas.lastEntry()
    }
    
    @State private var selectedDate: Date? = nil
    @State private var selectedPrice: Float? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
//            VStack (alignment: .leading) {
//                Text("Gas: EIP-1559")
////                    .font(.largeTitle)
//                    .bold()
////                Text("EIP-1559")
////                    .font(.caption)
//            }
//            .opacity(isExample ? 0.2 : 1)
//            .padding(.vertical, 2)
////                Spacer()
            
            if (selectedPrice != nil && selectedDate != nil) {
                VStack(alignment: .leading) {
                    Text(String(format: "%.2f", selectedPrice!))
                        .font(.system(size: 60, design: .rounded)).bold()
                        .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                        .lineLimit(1)
                        .foregroundStyle(
                            Color("low").gradient
                                .shadow(.inner(color: Color("lowLight").opacity(1), radius: 4, x: 0, y: 0))
                        )
                        .shadow(color: Color(.systemBackground), radius: 5)
                        .padding(.bottom, -10)
                        .padding(.top, -10)
                    Text(selectedDate!, format: .dateTime).font(.caption)
                }
            } else {
                NormalFastView(
                    isGas: true,
                    normal: lastGas?.value.normal ?? 0.0,
                    fast: lastGas?.value.fast ?? 0.0,
                    currency: nil
                )
            }
            if (!isExample) {
                Divider().padding(.top)
                GasIndexChart(
                    entries: entries,
                    min: (appDelegate.gasIndexEntriesMinMax.min ?? 0.0) * 0.98,
                    max: (appDelegate.gasIndexEntriesMinMax.max ?? 0.0) * 1.02,
                    selectedDate: $selectedDate,
                    selectedPrice: $selectedPrice
                )
//                    .padding(.vertical)
                    .frame(minHeight: 300)
                    .cornerRadius(5)
                    .backgroundStyle(Color.white)
            }
        }
    }
}

struct GasPriceView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            GasPriceView()
        }
    }
}

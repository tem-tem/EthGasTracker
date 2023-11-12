//
//  GasIndexFocus.swift
//  EthGasTracker
//
//  Created by Tem on 8/20/23.
//

import SwiftUI

struct GasIndexFocus: View {
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @EnvironmentObject var appDelegate: AppDelegate
    
    @Binding var selectedDate: Date?
    @Binding var selectedPrice: Float?

    var body: some View {
        VStack(spacing: 0) {
            HStack (spacing: 10) {
                GasScale(selectedPrice: $selectedPrice)
                    .opacity(.init(selectedPrice != nil ? 0 : 1))
                Spacer()
    //                .opacity(.init(selectedPrice != nil ? 0 : 1))
                VStack(spacing: 0) {
                    Text(String(format: "%.f", selectedPrice ?? appDelegate.gasLevel.currentGas ?? 0))
                        .font(.system(size: 60, weight: selectedPrice != nil ? .thin : .bold, design: .rounded))
                        // inner shadow
//                        .foregroundColor(.white)
                        .foregroundStyle(
                            appDelegate.gasLevel.color.gradient
                                .shadow(.inner(color: .white.opacity(0.5), radius: 2, x: 0, y: 0))
                        )
                    HStack {
                        Image(systemName: "info.circle").opacity(0)
                        Text("\(appDelegate.gasLevel.label)")
                        Image(systemName: "info.circle").opacity(0.5)
                    }
                        .font(.caption)
                        .bold()
                        .padding(.bottom)
                        .opacity(.init(selectedPrice != nil ? 0 : 1))
    //                HStack {
    ////                    Divider()
    //                }
                }
                Spacer()
                GasScale(selectedPrice: $selectedPrice)
                    .opacity(.init(selectedPrice != nil ? 0 : 1))
            }
            .foregroundColor(.init(selectedPrice != nil ? .primary : appDelegate.gasLevel.color))
    //
            .padding(.horizontal,20)
    //        .frame(height: )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
//                    .stroke(appDelegate.gasLevel.color, lineWidth: 1)
                    .stroke(LinearGradient(colors: [appDelegate.gasLevel.color, appDelegate.gasLevel.color.opacity(0.5)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
    //                        .background(Color.accentColor.gradient.opacity(0.1))
                    .background(appDelegate.gasLevel.color.opacity(0.01))
                    .background(
                        LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .top)
                    )
                    .background(
                        LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .bottom)
                    )
                    .background(
                        LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .topTrailing)
                    )
                    .background(
                        LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.05)]), startPoint: .center, endPoint: .topLeading)
                    )
                    .background(
                        LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0.1), appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0)]), startPoint: .leading, endPoint: .trailing)
                    )
                    .background(
                        LinearGradient(gradient: Gradient(colors: [appDelegate.gasLevel.color.opacity(0),appDelegate.gasLevel.color.opacity(0), appDelegate.gasLevel.color.opacity(0.1)]), startPoint: .leading, endPoint: .trailing)
                    )
                    .opacity(.init(selectedPrice != nil ? 0 : 1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            )
//            VStack(alignment: .leading) {
//                Text("USUAL GAS PRICE PERCENTILES")
//                    .font(.caption)
////                    .bold()
//                    .foregroundColor(Color.secondary)
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text("5th")
//                        Text(String(format: "%.f", appDelegate.currentStats.p5))
//                            .bold()
//                            .font(.body)
//                    }
//                    Spacer()
//                    VStack(alignment: .leading) {
//                        Text("25th")
//                        Text(String(format: "%.f", appDelegate.currentStats.p25))
//                            .bold()
//                            .font(.body)
//                    }
//                    Spacer()
//                    VStack(alignment: .leading) {
//                        Text("50th")
//                        Text(String(format: "%.f", appDelegate.currentStats.p50))
//                            .bold()
//                            .font(.body)
//                    }
//                    Spacer()
//                    VStack(alignment: .leading) {
//                        Text("75th")
//                        Text(String(format: "%.f", appDelegate.currentStats.p75))
//                            .bold()
//                            .font(.body)
//                    }
//                    Spacer()
//                    VStack(alignment: .leading) {
//                        Text("95th")
//                        Text(String(format: "%.f", appDelegate.currentStats.p95))
//                            .bold()
//                            .font(.body)
//                    }
//                }
//            }
//            .padding(.top)
////            .padding(.horizontal)
//            .font(.caption)
//            .foregroundColor(Color.secondary)
        }
    }
}

struct GasIndexFocus_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            GasIndexFocus(selectedDate: .constant(nil), selectedPrice: .constant(nil))
        }
    }
}

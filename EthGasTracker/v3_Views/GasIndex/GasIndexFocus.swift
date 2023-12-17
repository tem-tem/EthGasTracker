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
    @Binding var selectedHistoricalData: HistoricalData?
    var isActiveSelection: Bool
    
    var gasValue: Float {
        if let selectedPrice = selectedPrice {
            return selectedPrice
        }
        if let selectedHistoricalData = selectedHistoricalData {
            return selectedHistoricalData.avg
        }
        return appDelegate.gasLevel.currentGas
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack (spacing: 10) {
                GasScale(selectedPrice: $selectedPrice)
                    .opacity(.init(isActiveSelection ? 0 : 1))
                Spacer()
                VStack(spacing: 0) {
                    Text(String(format: "%.f", gasValue))
                        .font(.system(size: 60, weight: isActiveSelection ? .thin : .bold, design: .rounded))
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
                        .opacity(.init(isActiveSelection ? 0 : 1))
                }
                Spacer()
                GasScale(selectedPrice: $selectedPrice)
                    .opacity(.init(isActiveSelection ? 0 : 1))
            }
            .foregroundColor(.init(isActiveSelection ? .primary : appDelegate.gasLevel.color))
            .padding(.horizontal,20)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(LinearGradient(colors: [appDelegate.gasLevel.color, appDelegate.gasLevel.color.opacity(0.5)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
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
                    .opacity(.init(isActiveSelection ? 0 : 1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            )
        }
    }
}

struct GasIndexFocus_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            GasIndexFocus(selectedDate: .constant(nil), selectedPrice: .constant(nil), selectedHistoricalData: .constant(nil), isActiveSelection: false)
        }
    }
}

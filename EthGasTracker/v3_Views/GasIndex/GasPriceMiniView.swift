//
//  GasPriceMiniView.swift
//  EthGasTracker
//
//  Created by Tem on 8/10/23.
//

import SwiftUI

struct GasPriceMiniView: View {
    @AppStorage("isStale") var isStale = false
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @EnvironmentObject var appDelegate: AppDelegate
    
    var gasPrice: Float? {
        let lastEntry = appDelegate.gasIndexEntries.last
        return isFastMain ? lastEntry?.fast : lastEntry?.normal
    }
    
    @AppStorage(SettingsKeys().colorScheme) private var settingsColorScheme: ColorScheme = .none
    @Environment(\.colorScheme) private var defaultColorScheme
    var gasColor: Color {
        if defaultColorScheme == .light ||
            (
                defaultColorScheme == .none && defaultColorScheme == .light
            ) {
            return Color("avg")
        }
        return Color("avgLight")
    }
    
    var body: some View {
        ZStack {
            HStack {
//                TimestampView()
                Spacer()
            }
            HStack {
//                GasIndexChartMini(entries: appDelegate.gasIndexEntries, min: appDelegate.gasIndexEntriesMinMax.min, max: appDelegate.gasIndexEntriesMinMax.max)
//                    .padding(.leading, 150)
//                    .padding(.vertical, 3)
//                VStack(alignment: .leading) {
                Text("GAS").bold()
                    Text(String(format: "%.2f", gasPrice ?? 0))
                        .bold()
                        .foregroundColor(.accentColor)
//                }
            }
            .padding(.leading, 5)
            .opacity(isStale ? 0.6 : 1)
            .saturation(isStale ? 0 : 1)
            .animation(.easeInOut(duration: isStale ? 0.5 : 0.1), value: isStale)
        }
        .font(.system(.caption, design: .monospaced))
        .frame(height: 40)
        .font(.caption)
        .onAppear {
            print(settingsColorScheme)
            print(defaultColorScheme)
        }
    }
}

struct GasPriceMiniView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            GasPriceMiniView()
        }
    }
}

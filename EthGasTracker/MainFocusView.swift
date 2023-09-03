//
//  MainFocusView.swift
//  EthGasTracker
//
//  Created by Tem on 8/20/23.
//

import SwiftUI

struct MainFocusView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var selectedDate: Date? = nil
    @State private var selectedPrice: Float? = nil
    @State private var selectedKey: String? = nil
    @State private var showAlertsSheet = false
    @AppStorage(SettingsKeys().hapticFeedbackEnabled) private var haptic = true
    let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        VStack {
            EthPriceView(
                selectedKey: $selectedKey,
                selectedDate: $selectedDate
            )
                .padding(.horizontal)
                .padding(.vertical, 3)
                .font(.caption)
                .opacity(0.8)
            Divider()
            GasIndexFocus(selectedDate: $selectedDate, selectedPrice: $selectedPrice)
            ScrollView {
                ActionsListFocusView(actions: appDelegate.actions,
                                     selectedKey: $selectedKey)
            }
            .frame(minHeight: 250)
            .padding(.horizontal)
//            Spacer()
            ServerMessages(messages: appDelegate.serverMessages)
//                .padding()
            GasIndexChartFocus(
                entries: appDelegate.gasIndexEntries,
                min: appDelegate.gasIndexEntriesMinMax.min,
                max: appDelegate.gasIndexEntriesMinMax.max,
                selectedDate: $selectedDate,
                selectedPrice: $selectedPrice,
                selectedKey: $selectedKey
            )
            .frame(minHeight: 100)
            Spacer()
        }
        .onChange(of: selectedKey) { _ in
            if (haptic) {
                hapticFeedbackGenerator.impactOccurred()
            }
        }
    }
}

struct MainFocusView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            MainFocusView()
        }
    }
}

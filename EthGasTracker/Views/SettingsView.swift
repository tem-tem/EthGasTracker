//
//  SettingsView.swift
//  EthGasTracker
//
//  Created by Tem on 6/20/23.
//
import SwiftUI
import StoreKit

struct SettingsView: View {
    @AppStorage("settings.hapticFeedback") private var haptic = true
//    @AppStorage("settings.displayMode") var displayMode: DisplayMode = .none
    
    var body: some View {
        NavigationView {
            List {
                Section("App") {
                    HStack {
                        Image(systemName: "water.waves")
                        Toggle("Haptic Feedback", isOn: $haptic)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                }
                Section("About") {
                    HStack {
                        Image(systemName: "bubble.left")
                        FeedbackButton()
                    }
                    HStack {
                        Image(systemName: "hand.thumbsup")
                        Button("Rate the App") {
                            SKStoreReviewController.requestReview()
                        }.foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

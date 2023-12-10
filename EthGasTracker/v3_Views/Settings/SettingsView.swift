//
//  SettingsView.swift
//  EthGasTracker
//
//  Created by Tem on 6/20/23.
//
import SwiftUI
import StoreKit

struct SettingsKeys {
    let isFastMain = "settings.isFastMain"
    let hapticFeedbackEnabled = "settings.hapticFeedback"
    let useEIP1559 = "settings.useEIP1559"
    let colorScheme = "settings.colorScheme"
}

struct SettingsView: View {
    @AppStorage("subbed") var subbed: Bool = false
//    @Binding var isPresented: Bool
    @AppStorage(SettingsKeys().hapticFeedbackEnabled) private var haptic = true
    @State private var showToast: Bool = false
    @AppStorage("userSettings.colorScheme") var settingsColorScheme: ColorScheme = .none
    @Environment(\.colorScheme) private var defaultColorScheme
    @AppStorage(SettingsKeys().useEIP1559) private var useEIP1559 = true
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
//                    VStack(alignment: .center) {
//                        HStack {
//                            Spacer()
//                            Text("Settings")
//                                .font(.title)
//                            Spacer()
//                        }
//                    }
//                        .listRowBackground(Color.clear)
                    Section("App") {
                        HStack {
                            Image(systemName: "water.waves")
                                .frame(width: 32, height: 32)
                                .background(.teal, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            Toggle("Haptic Feedback", isOn: $haptic)
                                .toggleStyle(SwitchToggleStyle(tint: .green)).tint(.accentColor)
                        }
                        ColorSchemePickerView()
                        CurrencyListButtonView()
                        if (!subbed) {
                            SubscriptionView()
                        }
                    }
                    
                    Section("About") {
                        Link(destination: URL(string: "https://t.me/gas_app")!) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                    .frame(width: 32, height: 32)
                                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 8))
                                    .foregroundColor(.white)
                                Text("Telegram")
                            }
                        }
                        Link(destination: URL(string: "https://twitter.com/gas_devs")!) {
                            HStack {
                                Image(systemName: "bird")
                                    .frame(width: 32, height: 32)
                                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 8))
                                    .foregroundColor(.white)
                                Text("Twitter (𝕏)")
                            }
                        }
                        Link(destination: URL(string: "mailto:gas.app.developers@gmail.com?subject=Feedback")!) {
                            HStack {
                                Image(systemName: "bubble.left.fill")
                                    .frame(width: 32, height: 32)
                                    .background(Color("low"), in: RoundedRectangle(cornerRadius: 8))
                                    .foregroundColor(.white)
                                Text("gas.app.developers@gmail.com")
                            }
                        }
                        HStack {
                            Image(systemName: "hand.thumbsup.fill")
                                .frame(width: 32, height: 32)
                                .background(.orange, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            Button("Rate the App") {
                                SKStoreReviewController.requestReview()
                            }.foregroundColor(.primary)
                        }
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .frame(width: 32, height: 32)
                                .background(.red, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            Button("Share the App") {
                                UIPasteboard.general.string = "https://apps.apple.com/us/app/gas-alert-ethereum-gas-tracker/id6446234870"
                                showToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showToast = false
                                }
                            }.foregroundColor(.primary)
                        }
                    }
                    Section("Support Developers With Crypto") {
                        HStack {
                            VStack(alignment: .leading) {
                                Button("Copy ERC20 Address") {
                                    UIPasteboard.general.string = "0xeE197c3487883dF3A7d5Ab3d544166A90863379A"
                                    showToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showToast = false
                                    }
                                }
                                .foregroundColor(.primary)
                                .padding(.bottom, 1)
                                Text("0xeE197c3487883dF3A7d5Ab3d544166A90863379A")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                            }
                        }
//                        HStack {
////                            Image(systemName: "doc.on.doc")
//                            VStack(alignment: .leading) {
//                                Button("Copy TRC20 Address") {
//                                    UIPasteboard.general.string = "TKwVwWxVU6QCjSGqqGwpsmTqHsyUdCqNYW"
//                                    showToast = true
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                        showToast = false
//                                    }
//                                }.foregroundColor(.primary)
//                                .padding(.bottom, 1)
//                                Text("TKwVwWxVU6QCjSGqqGwpsmTqHsyUdCqNYW")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                                
//                            }
//                        }
                    }
                }
                .listStyle(.insetGrouped)
                
                if showToast {
                    VStack {
                        Spacer()
                        Text("Copied 🫡")
                            .padding()
                            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 8))
    //                        .background(Color.secondary)
                            .foregroundColor(.primary)
    //                        .cornerRadius(15)
                            .opacity(showToast ? 1 : 0)
                            .transition(.move(edge: .bottom))
                            .animation(.default, value: showToast)
                    }.padding()
                }
//                VStack {
//                    Spacer()
//                    Button("Dismiss") {
//                        isPresented = false
//                    }
//                }
            }
            .preferredColorScheme(
                settingsColorScheme == .dark ?
                    .dark :
                    settingsColorScheme == .light ? .light :
                    defaultColorScheme
            )
            
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
//    @State private var canShow = true
    static var previews: some View {
        PreviewWrapper {
            SettingsView()
        }
    }
}

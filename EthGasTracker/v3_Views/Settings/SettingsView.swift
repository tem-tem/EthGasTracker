//
//  SettingsView.swift
//  EthGasTracker
//
//  Created by Tem on 6/20/23.
//
import SwiftUI
import StoreKit

struct SettingsView: View {
    @Binding var isPresented: Bool
    @AppStorage("settings.hapticFeedback") private var haptic = true
    @State private var showToast: Bool = false
    @AppStorage("userSettings.colorScheme") var settingsColorScheme: ColorScheme = .none
    @Environment(\.colorScheme) private var defaultColorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section("App") {
                        HStack {
                            Image(systemName: "water.waves")
                                .frame(width: 32, height: 32)
                                .background(.teal, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            Toggle("Haptic Feedback", isOn: $haptic)
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                        }
                        ColorSchemePickerView()
                    }
                    Section("About") {
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
                    }
                    Section("Support Developers With Crypto") {
                        HStack {
                            VStack(alignment: .leading) {
                                Button("Copy ERC20 Address") {
                                    UIPasteboard.general.string = "0x28964B281E20afb8D9aF6184854dF605e342DFBB"
                                    showToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showToast = false
                                    }
                                }
                                .foregroundColor(.primary)
                                .padding(.bottom, 1)
                                Text("0x28964B281E20afb8D9aF6184854dF605e342DFBB")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                            }
                        }
                        HStack {
//                            Image(systemName: "doc.on.doc")
                            VStack(alignment: .leading) {
                                Button("Copy TRC20 Address") {
                                    UIPasteboard.general.string = "TKwVwWxVU6QCjSGqqGwpsmTqHsyUdCqNYW"
                                    showToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showToast = false
                                    }
                                }.foregroundColor(.primary)
                                .padding(.bottom, 1)
                                Text("TKwVwWxVU6QCjSGqqGwpsmTqHsyUdCqNYW")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                
                if showToast {
                    VStack {
                        Spacer()
                        Text("Address copied 🫡")
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
                VStack {
                    Spacer()
                    Button("Dismiss") {
                        isPresented = false
                    }
                }
            }
            
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(
            settingsColorScheme == .dark ?
                .dark :
                settingsColorScheme == .light ? .light :
                defaultColorScheme
        )
        
    }
}

struct SettingsView_Previews: PreviewProvider {
//    @State private var canShow = true
    static var previews: some View {
        SettingsView(isPresented: .constant(true) )
    }
}

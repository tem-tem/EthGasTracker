//
//  NotificationFormView.swift
//  EthGasTracker
//
//  Created by Tem on 8/14/23.
//

import SwiftUI
import FirebaseAnalytics

struct AlertFormView: View {
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @Binding var isPresented: Bool
    @EnvironmentObject var appDelegate: AppDelegate
    private var deviceToken: String? {
        appDelegate.deviceToken
    }
    
    private var gasPrice: Float? {
        let lastEntry = appDelegate.gasIndexEntries.last
        return isFastMain ? lastEntry?.fast : lastEntry?.normal
    }
    
    @State var gasThreshold = ""
    @State private var comparison: GasAlert.Condition.Comparison = .less_than
    @State private var mutePeriod = AlertLimit.thirty
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    GasPriceMiniView()
                        .padding(.vertical, 3)
                        .font(.caption)
                        .opacity(0.8)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
//                Section {
//                    HStack(alignment: .center) {
//                        Spacer()
//                        VStack {
//                            Image(systemName: "bell.and.waves.left.and.right.fill")
//                                .font(.largeTitle)
//                                .padding()
//                                .padding(.top)
//                            Text("New Alert")
//                                .font(.title)
//                                .bold()
//                        }
//                        .foregroundStyle(
//                            Color("avg").gradient
//                                .shadow(.inner(color: Color("avgLight").opacity(1), radius: 4, x: 0, y: 0))
//                        )
//                        Spacer()
//                    }
//                }
//                .listRowBackground(Color.clear)
//                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Section {
                    HStack {
                        
                        if ((Float(gasThreshold) ?? 0) <= (gasPrice ?? 0)) {
                            Image(systemName: "arrow.down")
                                .foregroundStyle(Color.accentColor)
                                .opacity(gasThreshold.count > 0 ? 1 : 0.3)
                        } else {
                            Image(systemName: "arrow.up")
                                .foregroundStyle(Color(.systemRed))
                                .opacity(gasThreshold.count > 0 ? 1 : 0.3)
                        }
                        TextField(String(format: "%.0f", gasPrice ?? 0), text: $gasThreshold)
                            .keyboardType(.decimalPad)
                            .onChange(of: gasThreshold) { newValue in
                                if let intValue = Int(newValue), intValue > 0 {
                                    gasThreshold = String(newValue.prefix(4))
                                } else {
                                    gasThreshold = ""
                                }
                            }
                    }
                    .font(.largeTitle)
                }.listRowSeparator(.hidden)
                
                
                Section {
//                    Picker("Condition", selection: $condition) {
//                        ForEach([GasAlert.Condition.Comparison.less_than, GasAlert.Condition.Comparison.greater_than], id: \.self) { comparison in
//    //                        HStack {
//                                if (comparison == .less_than) {
//                                    Image(systemName: "arrow.down")
//                                        .tag(comparison)
//                                } else {
//                                    Image(systemName: "arrow.up")
//                                        .tag(comparison)
//                                }
//    //                            Text(comparison.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))
//    //                        }
//                        }
//                    }
//                        .pickerStyle(.segmented)
                    
                    Picker("Limit", selection: $mutePeriod) {
                        ForEach(AlertLimit.allCases) { limit in
                            Text(limit.description).tag(limit)
                        }
                    }.pickerStyle(.navigationLink)
                }
                
                Section {
                    VStack {
                        Button {
                            guard let gasThresholdInt = Int(gasThreshold), gasThresholdInt > 0, gasThresholdInt < 9999, gasThreshold.count > 0 else {
                                return
                            }
                            guard let deviceToken = deviceToken, !deviceToken.isEmpty else {
                                return
                            }
                            
                            if (gasThresholdInt <= Int(gasPrice ?? 0)) {
                                comparison = .less_than
                            } else {
                                comparison = .greater_than
                            }

                            let condition = GasAlert.Condition(comparison: comparison, value: gasThresholdInt)
                            let alert = GasAlert(
                                id: nil,
                                deviceId: deviceToken,
                                mutePeriod: mutePeriod.rawValue,
                                conditions: [condition],
                                disabled: false,
                                legacyGas: false,
                                confirmationPeriod: 0,
                                disableAfterAlerts: 0,
                                disabledHours: []
//                                offHours: []
                            )
                            appDelegate.addAlert(alert: alert)
                            let params = [
                                AnalyticsParameterValue: gasThresholdInt,
                                AnalyticsParameterTerm: comparison.rawValue
                            ] as [String : Any]
                            Analytics.logEvent("add_alert", parameters: params)
                            isPresented = false
                        } label: {
                            HStack {
                                Spacer()
                                Text("Create")
                                    .padding(5)
                                Spacer()
                            }
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 25)
//                                    .stroke(Color.primary, lineWidth: 2)
//                                )
//                            .padding(2)
                        }
                            .buttonStyle(.borderedProminent)
                            .foregroundStyle(Color("BG"))
//                            .backgroundStyle(
//                                Color("avg").gradient
//                                    .shadow(.inner(color: Color("avgLight").opacity(1), radius: 4, x: 0, y: 0))
//                            )
                            .disabled(gasThreshold.count == 0)
                            .padding(.bottom)
                        Button {
                            isPresented = false
                        } label: {
                            Text("Cancel")
                        }
                    }
                }.listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}

struct AlertFormView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            AlertFormView(isPresented: .constant(false))
            
        }
    }
}

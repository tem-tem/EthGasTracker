////
////  NotificationFormView.swift
////  EthGasTracker
////
////  Created by Tem on 8/14/23.
////
//
//import SwiftUI
//import FirebaseAnalytics
//
//struct AlertFormView: View {
//    @AppStorage("subbed") var subbed: Bool = false
//    @AppStorage("requestReviewTimestamp") private var requestReviewTimestamp = 0.0
//    @Environment(\.requestReview) var requestReview
//    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
//    @Binding var isPresented: Bool
//    @EnvironmentObject var appDelegate: AppDelegate
//    private var deviceToken: String? {
//        appDelegate.deviceToken
//    }
//    
////    private var gasPrice:Double? {
////        let lastEntry = appDelegate..last
////        return isFastMain ? lastEntry?.fast : lastEntry?.normal
////    }
//    
//    @State var gasThreshold = ""
//    @State private var comparison: GasAlert.Condition.Comparison = .less_than
//    @State private var mutePeriod = AlertLimit.thirty
//    
//    @State private var showConfirmationPeriod = false
//    @State private var confirmationPeriod = AlertConfirmation.one
//    
//    @State private var showDisableAfter = false
//    @State private var disableAfterAlerts = AlertLifespan.one
//    
//    @State private var showOffHours = false
//    @State private var disabledHoursTo = Date()
//    @State private var disabledHoursFrom = Date()
//    
//    @State private var showSubscriptionView = false
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section {
//                    GasPriceMiniView()
//                        .padding(.vertical, 3)
//                        .font(.caption)
//                        .opacity(0.8)
//                }
//                .listRowBackground(Color.clear)
//                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                
////                Section {
////                    HStack(alignment: .center) {
////                        Spacer()
////                        VStack {
////                            Image(systemName: "bell.and.waves.left.and.right.fill")
////                                .font(.largeTitle)
////                                .padding()
////                                .padding(.top)
////                            Text("New Alert")
////                                .font(.title)
////                                .bold()
////                        }
////                        .foregroundStyle(
////                            Color("avg").gradient
////                                .shadow(.inner(color: Color("avgLight").opacity(1), radius: 4, x: 0, y: 0))
////                        )
////                        Spacer()
////                    }
////                }
////                .listRowBackground(Color.clear)
////                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                
//                Section {
//                    HStack {
//                        
//                        if ((Double(gasThreshold) ?? 0) <= (gasPrice ?? 0)) {
//                            Image(systemName: "arrow.down")
//                                .foregroundStyle(Color.accentColor)
//                                .opacity(gasThreshold.count > 0 ? 1 : 0.3)
//                        } else {
//                            Image(systemName: "arrow.up")
//                                .foregroundStyle(Color(.systemRed))
//                                .opacity(gasThreshold.count > 0 ? 1 : 0.3)
//                        }
//                        TextField(String(format: "%.0f", gasPrice ?? 0), text: $gasThreshold)
//                            .keyboardType(.decimalPad)
//                            .onChange(of: gasThreshold) { newValue in
//                                if let intValue = Int(newValue), intValue > 0 {
//                                    gasThreshold = String(newValue.prefix(4))
//                                } else {
//                                    gasThreshold = ""
//                                }
//                            }
//                    }
//                    .font(.largeTitle)
//                }.listRowSeparator(.hidden)
//                
//                
//                Section(footer: Text("Minimum time between notifications")) {
////                    Picker("Condition", selection: $condition) {
////                        ForEach([GasAlert.Condition.Comparison.less_than, GasAlert.Condition.Comparison.greater_than], id: \.self) { comparison in
////    //                        HStack {
////                                if (comparison == .less_than) {
////                                    Image(systemName: "arrow.down")
////                                        .tag(comparison)
////                                } else {
////                                    Image(systemName: "arrow.up")
////                                        .tag(comparison)
////                                }
////    //                            Text(comparison.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))
////    //                        }
////                        }
////                    }
////                        .pickerStyle(.segmented)
//                    
//                    Picker("Break", selection: $mutePeriod) {
//                        ForEach(AlertLimit.allCases) { limit in
//                            Text(limit.description).tag(limit)
//                        }
//                    }.pickerStyle(.navigationLink)
//                }
//                
//                Section(footer: Text("Get alerts only if gas satisfies the condition for a certain time.")) {
//                    if (subbed) {
//                        Toggle("Confirmation", isOn: $showConfirmationPeriod)
//                        
//                        if (showConfirmationPeriod) {
//                            Picker("Duration", selection: $confirmationPeriod) {
//                                ForEach(AlertConfirmation.allCases) { hold in
//                                    Text(hold.description).tag(hold)
//                                }
//                            }
//                        }
//                    } else {
//                        HStack {
//                            Text("Confirmation")
//                            Spacer()
//                            Button("Unlock") {
//                                showSubscriptionView = true
//                            }
//                                .sheet(isPresented: $showSubscriptionView) {
//                                    PurchaseView()
//                                }
//                        }
//                    }
//                }
//                
//                Section(footer: Text("No alerts during chosen hours.")) {
//                    if (subbed) {
//                        Toggle("Off Hours", isOn: $showOffHours)
//                            .toggleStyle(.switch)
//                        
//                        if (showOffHours) {
//                            DatePicker("Disable From", selection: $disabledHoursFrom, displayedComponents: .hourAndMinute)
//                            DatePicker("Disable To", selection: $disabledHoursTo, displayedComponents: .hourAndMinute)
//                        }
//                    } else {
//                        HStack {
//                            Text("Off Hours")
//                            Spacer()
//                            Button("Unlock") {
//                                showSubscriptionView = true
//                            }
//                                .sheet(isPresented: $showSubscriptionView) {
//                                    PurchaseView()
//                                }
//                        }
//                    }
//                }
//                
//                Section(footer: Text("Stops sending alerts after a certain number.")) {
//                    if (subbed) {
//                        Toggle("Limited Lifespan", isOn: $showDisableAfter)
//                            .toggleStyle(.switch)
//                        
//                        if (showDisableAfter) {
//                            Picker("Alerts", selection: $disableAfterAlerts) {
//                                ForEach(AlertLifespan.allCases) { lifespan in
//                                    Text(lifespan.description).tag(lifespan)
//                                }
//                            }
//                        }
//                    } else {
//                        HStack {
//                            Text("Limited Lifespan")
//                            Spacer()
//                            Button("Unlock") {
//                                showSubscriptionView = true
//                            }
//                                .sheet(isPresented: $showSubscriptionView) {
//                                    PurchaseView()
//                                }
//                        }
//                    }
//                }
//                
//                Section {
//                    VStack {
//                        Button {
//                            guard let gasThresholdInt = Int(gasThreshold), gasThresholdInt > 0, gasThresholdInt < 9999, gasThreshold.count > 0 else {
//                                return
//                            }
//                            guard let deviceToken = deviceToken, !deviceToken.isEmpty else {
//                                return
//                            }
//                            
//                            if (gasThresholdInt <= Int(gasPrice ?? 0)) {
//                                comparison = .less_than
//                            } else {
//                                comparison = .greater_than
//                            }
//
//                            let condition = GasAlert.Condition(comparison: comparison, value: gasThresholdInt)
//                            
//                            let disabledHoursFromSeconds = secondsSinceMidnightUTC(from: disabledHoursFrom)
//                            let disabledHoursToSeconds = secondsSinceMidnightUTC(from: disabledHoursTo)
//                            
//                            let alert = GasAlert(
//                                id: nil,
//                                deviceId: deviceToken,
//                                mutePeriod: mutePeriod.rawValue,
//                                conditions: [condition],
//                                disabled: false,
//                                legacyGas: false,
//                                confirmationPeriod: showConfirmationPeriod ? confirmationPeriod.rawValue : 0,
//                                disableAfterAlerts: showDisableAfter ? disableAfterAlerts.rawValue : 0,
//                                disabledHours: showOffHours ? [disabledHoursFromSeconds, disabledHoursToSeconds] : []
//                            )
//                            appDelegate.addAlert(alert: alert)
//                            let params = [
//                                AnalyticsParameterValue: gasThresholdInt,
//                                AnalyticsParameterTerm: comparison.rawValue
//                            ] as [String : Any]
//                            Analytics.logEvent("add_alert", parameters: params)
//                            isPresented = false
//                            askForReview()
//                        } label: {
//                            HStack {
//                                Spacer()
//                                Text("Create")
//                                    .padding(5)
//                                Spacer()
//                            }
////                            .overlay(
////                                RoundedRectangle(cornerRadius: 25)
////                                    .stroke(Color.primary, lineWidth: 2)
////                                )
////                            .padding(2)
//                        }
//                            .buttonStyle(.borderedProminent)
//                            .foregroundStyle(Color("BG"))
////                            .backgroundStyle(
////                                Color("avg").gradient
////                                    .shadow(.inner(color: Color("avgLight").opacity(1), radius: 4, x: 0, y: 0))
////                            )
//                            .disabled(gasThreshold.count == 0)
//                            .padding(.bottom)
//                        Button {
//                            isPresented = false
//                        } label: {
//                            Text("Cancel")
//                        }
//                    }
//                }.listRowBackground(Color.clear)
//                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//            }
//        }
//    }
//    
//    func askForReview() {
//        let twoWeeks = 14 * 24 * 60 * 60.0
//        let currentTime = Date.now.timeIntervalSince1970
//        
//        if (requestReviewTimestamp + twoWeeks < currentTime) {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
//                requestReview()
//                requestReviewTimestamp = Date.now.timeIntervalSince1970
//            }
//        }
//    }
//    
//    func secondsSinceMidnightUTC(from date: Date) -> Int {
//        // Convert to UTC
//        let utcCalendar = Calendar.current
//        let utcComponents = utcCalendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: date)
//        
//        // Extract hour and minute
//        guard let hour = utcComponents.hour, let minute = utcComponents.minute else {
//            return 0
//        }
//
//        // Calculate seconds since midnight
//        return hour * 3600 + minute * 60
//    }
//}
//
//struct AlertFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewWrapper {
//            AlertFormView(isPresented: .constant(false))
//            
//        }
//    }
//}

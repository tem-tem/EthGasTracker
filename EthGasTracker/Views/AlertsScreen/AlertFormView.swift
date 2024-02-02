//
//  NotificationFormView.swift
//  EthGasTracker
//
//  Created by Tem on 8/14/23.
//

import SwiftUI
import FirebaseAnalytics

struct AlertFormView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var alertVM: AlertVM
//    @Environment(\.requestReview) var requestReview
    @AppStorage("subbed") var subbed: Bool = false
    @AppStorage("requestReviewTimestamp") private var requestReviewTimestamp = 0.0
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @Binding var isPresented: Bool
//    @EnvironmentObject var appDelegate: AppDelegate
    private var deviceToken: String? {
        DeviceTokenManager.shared.deviceToken
    }
    private var gasPrice: Int? {
        Int(round(liveDataVM.gasLevel.currentGas))
    }
//    private var gasPrice:Double? {
//        let lastEntry = appDelegate..last
//        return isFastMain ? lastEntry?.fast : lastEntry?.normal
//    }
    
    @State var gasThreshold = ""
    @State private var comparison: Alert.Condition.Comparison = .less_than
    @State private var mutePeriod = AlertLimit.thirty
    
    @State private var showConfirmationPeriod = false
    @State private var confirmationPeriod = AlertConfirmation.one
    
    @State private var showDisableAfter = false
    @State private var disableAfterAlerts = AlertLifespan.one
    
    @State private var showOffHours = false
    @State private var disabledHoursTo = Date()
    @State private var disabledHoursFrom = Date()
    
    @State private var showSubscriptionView = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                HStack (alignment: .top) {
                    Image(systemName: "clock.badge.checkmark")
                        .frame(width: 32, height: 32)
                        .bold()
                    VStack (alignment: .leading) {
                        if (subbed) {
                            Toggle("Confirmation", isOn: $showConfirmationPeriod)
                                .toggleStyle(.switch)
                            if (showConfirmationPeriod) {
                                Picker("Duration", selection: $confirmationPeriod) {
        //                            Text("Disabled").tag("0")
                                    ForEach(AlertConfirmation.allCases) { hold in
                                        Text(hold.description).tag(hold)
                                    }
                                }
                                    .pickerStyle(.menu)
                                    .accentColor(liveDataVM.gasLevel.color)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10, style: .circular)
                                            .strokeBorder(liveDataVM.gasLevel.color, lineWidth: 1)
                                    }
                            }
                        } else {
                            HStack {
                                Text("Confirmation")
                                Spacer()
                                Button {
                                    showSubscriptionView = true
                                } label: {
                                    BorderedText(value: "Unlock")
                                }
                                .sheet(isPresented: $showSubscriptionView) {
                                    PurchaseView()
                                }
                            }
                        }
                        HStack {
                            Text("Notify only if gas satisfies the condition for a certain time")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Divider()
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            
                HStack (alignment: .top) {
                    Image(systemName: "moon.stars.fill")
                        .frame(width: 32, height: 32)
                        .bold()
                    VStack (alignment: .leading) {
                        if (subbed) {
                            Toggle("Off Hours", isOn: $showOffHours)
                                .toggleStyle(.switch)
                        } else {
                            HStack {
                                Text("Off Hours")
                                Spacer()
                                Button {
                                    showSubscriptionView = true
                                } label: {
                                    BorderedText(value: "Unlock")
                                }
                                    .sheet(isPresented: $showSubscriptionView) {
                                        PurchaseView()
                                    }
                            }
                        }
                        if (showOffHours) {
                            HStack {
                                DatePicker("Disable From", selection: $disabledHoursFrom, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                Text("-")
                                DatePicker("Disable To", selection: $disabledHoursTo, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                Spacer()
                            }
                        }
                        HStack {
                            Text("No alerts during chosen hours")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Divider()
                    }
                }
                .padding(.horizontal)
                
                HStack (alignment: .top) {
                    Image(systemName: "bolt.badge.clock")
                        .frame(width: 32, height: 32)
                        .bold()
    //                    .padding(.top, 6)
                    VStack (alignment: .leading) {
                        if (subbed) {
                            Toggle("Limited Lifespan", isOn: $showDisableAfter)
                                .toggleStyle(.switch)
                        } else {
                            HStack {
                                Text("Limited Lifespan")
                                Spacer()
                                Button {
                                    showSubscriptionView = true
                                } label: {
                                    BorderedText(value: "Unlock")
                                }
                                    .sheet(isPresented: $showSubscriptionView) {
                                        PurchaseView()
                                    }
                            }
                        }
                        if (showDisableAfter) {
                            HStack {
    //                            Text("Limit to")
    //                            Spacer()
                                Picker("Alerts", selection: $disableAfterAlerts) {
                                    ForEach(AlertLifespan.allCases) { lifespan in
                                        Text(lifespan.description).tag(lifespan)
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(liveDataVM.gasLevel.color)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10, style: .circular)
                                        .strokeBorder(liveDataVM.gasLevel.color, lineWidth: 1)
                                }
                            }
                        }
                        HStack {
                            Text("Stops sending alerts after a certain number")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Divider()
                    }
                }
                .padding(.horizontal)
                
                HStack (alignment: .top) {
                    Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                        .frame(width: 32, height: 32)
                        .bold()
    //                    .padding(.top, 6)
                    VStack (alignment: .leading) {
                        HStack {
                            Text("Break")
                            Spacer()
                            Picker("Break", selection: $mutePeriod) {
                                ForEach(AlertLimit.allCases) { limit in
                                    Text(limit.description).tag(limit)
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(liveDataVM.gasLevel.color)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .circular)
                                    .strokeBorder(liveDataVM.gasLevel.color, lineWidth: 1)
                            }
                        }
                        HStack {
                            Text("Minimum time between notifications")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            
            Divider()
            
            HStack {
                
                if (Int(gasThreshold) ?? 0 <= gasPrice ?? 0) {
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
                    .focused($isTextFieldFocused)
                    .onAppear {
                        isTextFieldFocused = true
                    }
                    .padding(.vertical)
            }
                .font(.largeTitle)
                .padding(.horizontal)
            
            VStack {
                Button {
                    guard let gasThresholdInt = Int(gasThreshold), gasThresholdInt > 0, gasThresholdInt < 9999, gasThreshold.count > 0 else {
                        return
                    }
                    guard let deviceToken = deviceToken, !deviceToken.isEmpty else {
                        return
                    }
                    
                    if (gasThresholdInt <= gasPrice ?? 0) {
                        comparison = .less_than
                    } else {
                        comparison = .greater_than
                    }

                    let condition = Alert.Condition(comparison: comparison, value: gasThresholdInt)
                    
                    let disabledHoursFromSeconds = secondsSinceMidnightUTC(from: disabledHoursFrom)
                    let disabledHoursToSeconds = secondsSinceMidnightUTC(from: disabledHoursTo)
                    
                    let alert = Alert(
                        id: nil,
                        deviceId: deviceToken,
                        mutePeriod: mutePeriod.rawValue,
                        conditions: [condition],
                        disabled: false,
                        legacyGas: false,
                        confirmationPeriod: showConfirmationPeriod ? confirmationPeriod.rawValue : 0,
                        disableAfterAlerts: showDisableAfter ? disableAfterAlerts.rawValue : 0,
                        disabledHours: showOffHours ? [disabledHoursFromSeconds, disabledHoursToSeconds] : []
                    )
                    alertVM.add(alert: alert)
                    let params = [
                        AnalyticsParameterValue: gasThresholdInt,
                        AnalyticsParameterTerm: comparison.rawValue
                    ] as [String : Any]
                    Analytics.logEvent("add_alert", parameters: params)
                    isPresented = false
                    askForReview()
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
                    .backgroundStyle(liveDataVM.gasLevel.color)
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
                        .foregroundStyle(liveDataVM.gasLevel.color)
                }
            }
            .padding(.horizontal)
        }.scrollContentBackground(.hidden)
            .padding(.bottom)
    }
    
    func askForReview() {
        let twoWeeks = 14 * 24 * 60 * 60.0
        let currentTime = Date.now.timeIntervalSince1970
        
        if (requestReviewTimestamp + twoWeeks < currentTime) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
//                requestReview()
                requestReviewTimestamp = Date.now.timeIntervalSince1970
            }
        }
    }
    
    func secondsSinceMidnightUTC(from date: Date) -> Int {
        // Convert to UTC
        let utcCalendar = Calendar.current
        let utcComponents = utcCalendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: date)
        
        // Extract hour and minute
        guard let hour = utcComponents.hour, let minute = utcComponents.minute else {
            return 0
        }

        // Calculate seconds since midnight
        return hour * 3600 + minute * 60
    }
}

//struct AlertFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewWrapper {
//            AlertFormView(isPresented: .constant(false))
//            
//        }
//    }
//}

#Preview {
    PreviewWrapper {
        AlertFormView(isPresented: .constant(true))
    }
}

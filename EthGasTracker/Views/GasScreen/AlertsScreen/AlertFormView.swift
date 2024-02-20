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
    @Binding var showToast: Bool
    
    var alert: Alert? = nil
    var isEditing: Bool {
        alert != nil
    }
    
    private var deviceToken: String? {
        DeviceTokenManager.shared.deviceToken
    }
    private var gasPrice: Int? {
        Int(round(liveDataVM.gasLevel.currentGas))
    }
    
    @State var gasThreshold: String
    @State private var mutePeriod = AlertLimit.thirty
    
    @State private var showConfirmationPeriod = false
    @State private var confirmationPeriod = AlertConfirmation.one
    
    @State private var showDisableAfter = false
    @State private var disableAfterAlerts = AlertLifespan.one
    
    @State private var showOffHours = false
    @State private var disabledHoursTo = Date()
    @State private var disabledHoursFrom = Date()
    
    @State private var showSubscriptionView = false
    @State private var showingOptions = false
    
    private var currentAlert: Alert? {
        guard let gasThresholdInt = Int(gasThreshold), gasThresholdInt > 0, gasThresholdInt < 9999, gasThreshold.count > 0 else {
            return nil
        }
        guard let deviceToken = deviceToken, !deviceToken.isEmpty else {
            return nil
        }
        
        let comparison: Alert.Condition.Comparison = gasThresholdInt <= gasPrice ?? 0 ? .less_than : .greater_than
        let condition = Alert.Condition(comparison: comparison, value: gasThresholdInt)
        
        let disabledHoursFromSeconds = secondsSinceMidnightUTC(from: disabledHoursFrom)
        let disabledHoursToSeconds = secondsSinceMidnightUTC(from: disabledHoursTo)
        
        return Alert(
            id: alert?.id,
            deviceId: deviceToken,
            mutePeriod: mutePeriod.rawValue,
            conditions: [condition],
            disabled: false,
            legacyGas: false,
            confirmationPeriod: showConfirmationPeriod ? confirmationPeriod.rawValue : 0,
            disableAfterAlerts: showDisableAfter ? disableAfterAlerts.rawValue : 0,
            disabledHours: showOffHours ? [disabledHoursFromSeconds, disabledHoursToSeconds] : []
        )
    }
    
    init(isPresented: Binding<Bool>, showToast: Binding<Bool>, alert: Alert? = nil) {
        self._isPresented = isPresented
        self._showToast = showToast
        self.alert = alert
        if let alert = alert, let condition = alert.conditions.first(where: { $0.value > 0 }) {
            _gasThreshold = State(initialValue: "\(condition.value)")
            _mutePeriod = State(initialValue: AlertLimit(rawValue: alert.mutePeriod) ?? .thirty)
            _showConfirmationPeriod = State(initialValue: alert.confirmationPeriod > 0)
            _confirmationPeriod = State(initialValue: AlertConfirmation(rawValue: alert.confirmationPeriod) ?? .one)
            _showDisableAfter = State(initialValue: alert.disableAfterAlerts ?? 0 > 0)
            _disableAfterAlerts = State(initialValue: AlertLifespan(rawValue: alert.disableAfterAlerts ?? 0) ?? .one)
            if let from = alert.disabledHours.first, let to = alert.disabledHours.last, to - from > 0 {
                _showOffHours = State(initialValue: true)
                _disabledHoursTo = State(initialValue: Date(timeIntervalSince1970: TimeInterval(to)))
                _disabledHoursFrom = State(initialValue: Date(timeIntervalSince1970: TimeInterval(from)))
            }
        } else {
            _gasThreshold = State(initialValue: "")
        }
    }
    
    var body: some View {
        let alreadyExists = alertVM.exists(alert: currentAlert)
        let didEdit = alert?.id != nil && !alreadyExists
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    if (alreadyExists && !isEditing) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("Already exists")
                        }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 10)
                            .font(.caption)
                            .background(.thinMaterial)
                            .cornerRadius(10)
                            .foregroundStyle(.orange)
                            .opacity(alreadyExists ? isEditing ? 0 : 1 : 0)
                    } else {
                        Text(geometry.size.height > 600 ? "Options" : "Swipe up to see more options")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 2)
                    }
                }
                .padding(.top)
                .padding(.vertical)
                
                if geometry.size.height > 600 {
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
                }
                
                Spacer()
                Divider()
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        if (!gasThreshold.isEmpty) {
                            if (Int(gasThreshold) ?? 0 <= gasPrice ?? 0) {
                                Image(systemName: "arrow.down")
                                    .foregroundStyle(Color.accentColor)
                            } else {
                                Image(systemName: "arrow.up")
                                    .foregroundStyle(Color(.systemRed))
                            }
                        }
                        
                        Text(gasThreshold)
                            .padding(.vertical)
                            .bold()
                        
                        Image(systemName: "arrow.up")
                            .foregroundStyle(Color(.systemRed))
                            .opacity(0)
                        Spacer()
                    }
                    .frame(height: 70)
                    .font(.largeTitle)
                    .padding(.horizontal)
                }
//                .frame(height: 100)
                CustomNumberPadView(value: $gasThreshold, canCreate: alreadyExists && isEditing || !alreadyExists, onCommit: {
                    guard let alert = currentAlert else { return }
                    
                    if isEditing {
                        alertVM.update(alert: alert)
                    } else {
                        alertVM.add(alert: alert)
                    }
                    
                    isPresented = false
                    showToast.toggle()
                })
                
                VStack {
                    HStack {
                        Button {
                            isPresented = false
                        } label: {
                            Text("Cancel")
                                .foregroundStyle(liveDataVM.gasLevel.color)
                                .padding(.vertical, 5)
                        }
                    }
                }
                .padding(.horizontal)
            }.scrollContentBackground(.hidden)
                .padding(.bottom)
        }
        
    }
    
//    func askForReview() {
//        let twoWeeks = 14 * 24 * 60 * 60.0
//        let currentTime = Date.now.timeIntervalSince1970
//        
//        if (requestReviewTimestamp + twoWeeks < currentTime) {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
////                requestReview()
//                requestReviewTimestamp = Date.now.timeIntervalSince1970
//            }
//        }
//    }
    
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
        AlertFormView(isPresented: .constant(true), showToast: .constant(true))
    }
}

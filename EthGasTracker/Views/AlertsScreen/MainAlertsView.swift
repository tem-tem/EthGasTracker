//
//  MainAlertsView.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import SwiftUI
import AlertToast

struct MainAlertsView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var alertVM: AlertVM
//    @Binding var showingAlertForm: Bool
    @State private var showingNewAlertForm = false
    @State private var showToast = false
    
    var body: some View {
        VStack (spacing: 0) {
            if (alertVM.alerts.count > 0) {
                ScrollView {
                    ForEach(alertVM.alerts) {alert in
                        AlertView(alert: alert, showToast: $showToast)
                            .opacity(alert.disabled ?? false ? 0.4 : 1)
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                    }
                }.refreshable {
                    alertVM.fetch()
                }
                Divider()
                Button {
                    showingNewAlertForm = true
                } label: {
                    BorderedText(value: "Add Alert")
                }.padding()
            } else {
                Spacer()
                Image(systemName: "bell.and.waves.left.and.right")
                    .font(.largeTitle)
                    .padding(.bottom, 20)
                    .foregroundStyle(.secondary)
                Text("No Alerts")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)
                Text("Alert is a Push Notification for specific gas price conditions.")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                Spacer()
                Button {
                    showingNewAlertForm = true
                } label: {
                    BorderedText(value: "Add Alert")
                        .font(.largeTitle)
                }.padding()
                Spacer()
            }
        }
        .toast(isPresenting: $showToast, duration: 1.0, tapToDismiss: true){
            AlertToast(type: .systemImage("checkmark", liveDataVM.gasLevel.color))
        }
        .sheet(isPresented: $showingNewAlertForm) {
            AlertFormView(isPresented: $showingNewAlertForm, showToast: $showToast)
                .background(Color("BG.L1"))
                .presentationDetents([.medium, .large])
//                .overlay {
//                    GeometryReader { geometry in
//                        Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
//                    }
//                }
//                .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
//                    sheetHeight = newHeight
//                }
//                .presentationDetents([.height(500)])
        }
    }
}

#Preview {
    PreviewWrapper {
        MainAlertsView()
    }
}


func timeString(from seconds: Int) -> String {
    if seconds < 60 {
        return "\(seconds) seconds"
    } else if seconds < 3600 {
        return "\(seconds / 60) minutes"
    } else {
        let hours = seconds / 3600
        return hours == 1 ? "\(hours) hour" : "\(hours) hours"
    }
}

struct OffHoursView: View {
    var from: Int // Assuming AlertDetails is a struct with disabledHours
    var to: Int

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current // Set to the user's current locale
        formatter.timeZone = TimeZone.current // Adjust for local timezone
        formatter.dateStyle = .none // No date
        formatter.timeStyle = .short // Time with hours and minutes
        return formatter
    }

    var body: some View {
        // Creating a formatter for time display
//        let dateFormatter = DateFormatter.customDateFormatter(withFormat: "HH:mm")
//        dateFormatter.timeZone = TimeZone.current

        // Convert 'from' and 'to' from seconds to local time strings
        let fromTimeString = secondsToTimeString(from, using: dateFormatter)
        let toTimeString = secondsToTimeString(to, using: dateFormatter)

        // Displaying the time range
        Text("\(fromTimeString) - \(toTimeString)").bold()
    }

    // Function to convert seconds since midnight to a time string
    private func secondsToTimeString(_ seconds: Int, using formatter: DateFormatter) -> String {
        let utcMidnight = Calendar.current.startOfDay(for: Date())
        let date = utcMidnight.addingTimeInterval(TimeInterval(seconds))
        let dateInLocalTime = date.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
        return formatter.string(from: dateInLocalTime)
    }
}

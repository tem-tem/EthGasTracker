//
//  MainAlertsView.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import SwiftUI

struct MainAlertsView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var alertVM: AlertVM
    @Binding var showingAlertForm: Bool
    
    var body: some View {
        VStack (spacing: 0) {
            if (alertVM.alerts.count > 0) {
                ScrollView {
                    ForEach(alertVM.alerts) {alert in
                        AlertView(alert: alert)
                            .opacity(alert.disabled ?? false ? 0.4 : 1)
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                    }.onDelete { offsets in
                        offsets.forEach { index in
                            if let alertId = alertVM.alerts[index].id {
                                alertVM.delete(id: alertId)
                            }
                        }
                        alertVM.alerts.remove(atOffsets: offsets)
                    }
                }
            } else {
                Spacer()
                Image(systemName: "bell.and.waves.left.and.right")
                    .font(.largeTitle)
                    .padding(40)
                    .foregroundStyle(.secondary)
                Text("Get notified when gas prices change")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            Divider()
            Button {
                showingAlertForm = true
            } label: {
                BorderedText(value: "Add Alert")
            }.padding()
        }
    }
}

#Preview {
    PreviewWrapper {
        MainAlertsView(showingAlertForm: .constant(false))
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

//
//  NotificationsTabView.swift
//  EthGasTracker
//
//  Created by Tem on 8/12/23.
//

import SwiftUI

struct AlertsTabView: View {
    @AppStorage("subbed") var subbed: Bool = false
    @EnvironmentObject var appDelegate: AppDelegate
    private var deviceToken: String? {
        appDelegate.deviceToken
    }
    var alertList: [GasAlert] {
        appDelegate.alerts
    }
    
    @State private var showingForm = false
    private let addId = UUID().uuidString
    
    @State private var showingPurchaseScreen = false
    
//    @State private var alertList: [GasAlert] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(appDelegate.alerts) {alert in
                        VStackWithRoundedBorder {
                            Toggle(isOn: Binding(
                                get: { !(alert.disabled ?? false) },
                                set: { newValue in
                                    guard let alertId = alert.id else { return }
                                    appDelegate.toggleAlert(by: alertId)
                                })) {
                                    AlertConditionView(conditions: alert.conditions)
                                        .padding(.bottom, 4)
                                }.tint(.accentColor)
                            
                            VStack {
                                HStack {
                                    Text("Break")
                                    Spacer()
                                    Text(timeString(from: alert.mutePeriod)).bold()
                                    
                                }
                                Divider()
                                HStack {
                                    if let from = alert.disabledHours.first, let to = alert.disabledHours.last, from > 0 {
                                        Text("Off Hours")
                                        Spacer()
                                        OffHoursView(from: from, to: to)
                                    } else {
                                        Text("Off Hours").opacity(0.4)
                                        Spacer()
                                        Text("Not Set").bold().opacity(0.4)
                                    }
                                }
                                Divider()
                                HStack {
                                    if let confirmation = AlertConfirmation(rawValue: alert.confirmationPeriod) {
                                        Text("Confirmation")
                                        Spacer()
                                        Text(confirmation.description).bold()
                                    } else {
                                        Text("Confirmation").opacity(0.4)
                                        Spacer()
                                        Text("Not Set").bold().opacity(0.4)
                                    }
                                }
                                Divider()
                                HStack {
                                    if let lifespan = alert.disableAfterAlerts, lifespan > 0 {
                                        Text("Lifespan")
                                        Spacer()
                                        Text("\(lifespan)").bold()
                                    } else {
                                        Text("Lifespan").opacity(0.4)
                                        Spacer()
                                        Text("Not Set").bold().opacity(0.4)
                                    }
                                }
                            }.font(.caption)
                        }
                            .opacity(alert.disabled ?? false ? 0.4 : 1)
                    }.onDelete { offsets in
                        offsets.forEach { index in
                            if let alertId = appDelegate.alerts[index].id {
                                appDelegate.deleteAlert(by: alertId)
                            }
                        }
                        appDelegate.alerts.remove(atOffsets: offsets)
                    }
                    if (appDelegate.alerts.count > 2) {
                        Spacer(minLength: 100)
                    }
                }
                .listStyle(.plain)
                VStack(spacing: 0) {
                    Spacer()
                    
                    if (!subbed && alertList.count > FREE_ALERTS_LIMIT - 1) {
                        Button {
                            showingPurchaseScreen = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Add")
                                    .padding(5)
                                Spacer()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(Color("BG"))
                        .sheet(isPresented: $showingPurchaseScreen) {
                            PurchaseView()
                        }
                        .id(addId)
                        .padding()
                        .padding(.bottom)
                    } else {
                        Button {
                            showingForm = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Add")
                                    .padding(5)
                                Spacer()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(Color("BG"))
                        .sheet(isPresented: $showingForm) {
                            AlertFormView(isPresented: $showingForm)
                        }
                        .id(addId)
                        .padding()
                        .padding(.bottom)
                    }
//                    HStack {
//                        EditButton()
//                            .frame(minWidth: 100)
//                            .padding(.horizontal, 10)
//                    }.padding().background(.regularMaterial)
                }
                
//                .toolbar {
//                }
//                .toolbar {
//                    ToolbarItem(placement: .bottomBar) {
//                    }
//                }
                
            }.navigationTitle("Alerts")
                .navigationViewStyle(StackNavigationViewStyle())
        }
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

struct AlrertsTabView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            AlertsTabView()
        }
    }
}

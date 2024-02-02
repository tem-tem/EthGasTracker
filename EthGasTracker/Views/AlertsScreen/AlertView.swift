//
//  AlertView.swift
//  EthGasTracker
//
//  Created by Tem on 1/24/24.
//

import SwiftUI

struct AlertView: View {
    @EnvironmentObject var alertVM: AlertVM
    let alert: Alert
    
    var body: some View {
        VStackWithRoundedBorder {
            Toggle(isOn: Binding(
                get: { !(alert.disabled ?? false) },
                set: { newValue in
                    guard let alertId = alert.id else { return }
                    alertVM.toggle(id: alertId)
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
            
            if let id = alert.id {
                HStack {
                    Spacer()
                    Button {
                        alertVM.delete(id: id)
                    } label: {
                        BorderedText(value: "Delete")
                    }
                }
            }
        }
    }
}

#Preview {
    AlertView(alert: Alert(id: "123", deviceId: "123", mutePeriod: 30, conditions: [Alert.Condition(comparison: .greater_than, value: 30)], legacyGas: false, confirmationPeriod: 100, disableAfterAlerts: 1, disabledHours: [100, 200]))
        .environmentObject(AlertVM(apiManager: apiManager))
        .environmentObject(AppDelegate())
}

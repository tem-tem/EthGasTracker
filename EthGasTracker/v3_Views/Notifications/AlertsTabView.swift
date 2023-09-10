//
//  NotificationsTabView.swift
//  EthGasTracker
//
//  Created by Tem on 8/12/23.
//

import SwiftUI

struct AlertsTabView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    private var deviceToken: String? {
        appDelegate.deviceToken
    }
    var alertList: [GasAlert] {
        appDelegate.alerts
    }
    
    @State private var showingForm = false
    private let addId = UUID().uuidString
    
//    @State private var alertList: [GasAlert] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(appDelegate.alerts) {alert in
                        Toggle(isOn: Binding(
                            get: { !(alert.disabled ?? false) },
                            set: { newValue in
                                guard let alertId = alert.id else { return }
                                appDelegate.toggleAlert(by: alertId)
                            })) {
                                VStack(alignment: .leading) {
                                    AlertConditionView(conditions: alert.conditions)
                                        .padding(.bottom, 4)
                                    Text("Once per ").font(.caption) +
                                    Text(timeString(from: alert.mutePeriod)).font(.caption).bold()
                                }.opacity(alert.disabled ?? false ? 0.4 : 1)
                            }.tint(.accentColor)
                    }.onDelete { offsets in
                        offsets.forEach { index in
                            if let alertId = appDelegate.alerts[index].id {
                                appDelegate.deleteAlert(by: alertId)
                            }
                        }
                        appDelegate.alerts.remove(atOffsets: offsets)
                    }
                }
                .listStyle(.plain)
                VStack(spacing: 0) {
                    Spacer()
                    
                    
                    if (alertList.count < 3) {
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

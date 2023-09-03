//
//  ThresholdListView.swift
//  EthGasTracker
//
//  Created by Tem on 4/16/23.
//

import SwiftUI

struct ThresholdListView: View {
    @Binding var deleting: Bool
    
    @EnvironmentObject var appDelegate: AppDelegate
    @ThresholdsStorage(key: "thresholds") var thresholds: [Threshold] = []
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        ForEach(thresholds) { threshold in
            VStack (alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        if (threshold.comparison == "less_than_or_equal_to") {
                            Text("Average ≤ \(Int(threshold.thresholdPrice))")
                                .font(.largeTitle)
                                .fontWeight(.thin)
                                .foregroundColor(threshold.enabled ?? false ? .primary : .secondary)
                        } else {
                            Text("Average is \(Int(threshold.thresholdPrice))+")
                                .font(.largeTitle)
                                .fontWeight(.thin)
                                .foregroundColor(threshold.enabled ?? false ? .primary : .secondary)
                        }
                        if (threshold.mute_duration < 300) {
                            Text("Not limited").foregroundColor(.orange)
                                .font(.caption)
                                .fontWeight(.thin)
                                .foregroundColor(threshold.enabled ?? false ? .orange : .secondary)
                        } else {
                            Text("One per \(AlertLimit(rawValue: threshold.mute_duration)?.description ?? "")")
                                .font(.caption)
                                .fontWeight(.thin)
                                .foregroundColor(threshold.enabled ?? false ? .primary : .secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if (deleting) {
                        Button(action: {
                            deleteThreshold(threshold: threshold, thresholds: &thresholds, last: thresholds.count == 1)
                        }) {
                            Image(systemName: "minus.circle")
                                .tint(.red)
                                .font(.largeTitle)
                            
                        }
                    } else {
                        Toggle("", isOn: Binding(
                            get: { threshold.enabled ?? false },
                            set: { newValue in
                                let action = newValue ? "add" : "remove"
                                sendThresholdHandler(action: action, appDelegate: appDelegate, thresholdPrice: "\(Int(threshold.thresholdPrice))", comparison: threshold.comparison, mute_duration: threshold.mute_duration)
                            }
                        ))
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                    
                }.frame(height: 75)
                Divider()
                
            }
        }
    }
    
    func deleteThreshold(threshold: Threshold, thresholds: inout [Threshold], last: Bool) {
        sendThresholdHandler(action: last ? "remove_all" : "remove", appDelegate: appDelegate, thresholdPrice: "\(threshold.thresholdPrice)", comparison: threshold.comparison, mute_duration: threshold.mute_duration)
        let thresholdId = threshold.id
        if let index = thresholds.firstIndex(where: { $0.id == thresholdId }) {
            thresholds.remove(at: index)
        }
    }

    
    func sendThresholdHandler(action: String, appDelegate: AppDelegate, thresholdPrice: String, comparison: String, mute_duration: Int) {
        if let deviceToken = appDelegate.deviceToken {
            sendThresholdPrice(
                action: action,
                deviceToken: deviceToken,
                threshold: thresholdPrice,
                comparison: comparison,
                mute_duration: mute_duration
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let newThresholds):
                        print(newThresholds)
//                        DispatchQueue.main.async {
//                            self.thresholds = newThresholds
//                        }
                        // Find the threshold by thresholdPrice and set its enabled property to false
                        self.updateThresholdEnabled(thresholdPrice: thresholdPrice, enabled: action == "add")
                        
                    case .failure(let error):
                        alertTitle = "Error"
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                }
            }
        } else {
            alertTitle = "Error"
            alertMessage = "Failed to obtain device token"
            showAlert = true
        }
    }
    
    func updateThresholdEnabled(thresholdPrice: String, enabled: Bool) {
        for (index, threshold) in thresholds.enumerated() {
            if threshold.thresholdPrice == Double(thresholdPrice) {
                thresholds[index].enabled = enabled
                break
            }
        }
    }
}

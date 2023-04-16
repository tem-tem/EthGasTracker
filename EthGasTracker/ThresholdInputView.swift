//
//  ThresholdInputView.swift
//  EthGasTracker
//
//  Created by Tem on 4/16/23.
//

import SwiftUI

struct ThresholdInputView: View {
    var onSubmit: (_: Bool) -> Void
    
    @EnvironmentObject var appDelegate: AppDelegate
    @AppStorage("ProposeGasPrice") var avg = "00"
    @ThresholdsStorage(key: "thresholds") var thresholds: [Threshold] = []
    @State private var thresholdPrice: String = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var comparison = "less_than_or_equal_to"
    @State private var displayComparison = "LOWER"
    
    private enum Field: Int, Hashable {
        case threshold
    }
    
    @FocusState private var focusedField: Bool
    
    var body: some View {
        VStack (alignment: .center) {
            Text("Current average is \(avg)")
            Spacer()
            Text("You will be notified when")
            Text("gas is ") + Text(displayComparison).bold().foregroundColor(displayComparison == "LOWER" ? .green : .red) + Text(" than")
            
            TextField(avg, text: $thresholdPrice)
                .keyboardType(.decimalPad)
                .padding()
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .focused($focusedField, equals: true)

            Spacer()
            Button(action: {
                sendThresholdHandler(action: "add", appDelegate: appDelegate, thresholdPrice: thresholdPrice, comparison: comparison)
            }) {
                Text("Set Threshold Price")
                    .foregroundColor(Color(.systemBackground))
                    .padding()
                    .background(Color.primary)
                    .cornerRadius(100)
            }
        }.onAppear {
            focusedField = true
        }
        .onChange(of: thresholdPrice, perform: {newThresholdPrice in
            if (Float(newThresholdPrice) ?? 0 < Float(avg) ?? 0) {
                comparison = "less_than_or_equal_to"
                displayComparison = "LOWER"
            }
            if (Float(newThresholdPrice) ?? 0 > Float(avg) ?? 0) {
                comparison = "greater_than"
                displayComparison = "HIGHER"
            }
        })
    }
    
    func sendThresholdHandler(action: String, appDelegate: AppDelegate, thresholdPrice: String, comparison: String) {
        if let deviceToken = appDelegate.deviceToken {
            sendThresholdPrice(
                action: action,
                deviceToken: deviceToken,
                threshold: thresholdPrice,
                comparison: comparison,
                mute_duration: 10
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let newThresholds):
                        DispatchQueue.main.async {
                            self.thresholds.append(newThresholds.last!)
                        }
                        onSubmit(true)
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
        
        onSubmit(false)
    }
}

struct ThresholdInputView_Previews: PreviewProvider {
    static var previews: some View {
        ThresholdInputView(onSubmit: {result in
            print(result)
        })
    }
}

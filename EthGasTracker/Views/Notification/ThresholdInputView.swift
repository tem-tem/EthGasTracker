//
//  ThresholdInputView.swift
//  EthGasTracker
//
//  Created by Tem on 4/16/23.
//

import SwiftUI
import StoreKit

struct ThresholdInputView: View {
    var onSubmit: (_: Bool) -> Void
    
    @EnvironmentObject var appDelegate: AppDelegate
    
    @Environment(\.requestReview) var requestReview
    @AppStorage("requestReviewTimestamp") private var requestReviewTimestamp = 0.0
    
    @AppStorage("ProposeGasPrice") var avg = "00"
    @ThresholdsStorage(key: "thresholds") var thresholds: [Threshold] = []
    @State private var thresholdPrice: String = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var comparison = "less_than_or_equal_to"
    @State private var displayComparison = "LOWER/HIGHER"
    @State private var displayComparisonColor = Color.blue
    
    @State private var selectedLimit = NotificationLimit.thirty
    
    private enum Field: Int, Hashable {
        case threshold
    }
    
    @FocusState private var focusedField: Bool
    
    var body: some View {
        VStack (alignment: .center) {
            Text("Current average is \(avg) gwei").font(.caption)
            Spacer()
            Text("Alert when")
            Text("gas is ") +
            Text(displayComparison)
                .bold()
                .foregroundColor(displayComparisonColor) +
            Text(" than")
            
            TextField(avg, text: $thresholdPrice)
                .keyboardType(.decimalPad)
                .padding()
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .focused($focusedField, equals: true)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Button(action: {
                            hideKeyboard()
                        }) {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    }
                }
            Divider()
            NotificationLimitPicker(selectedLimit: $selectedLimit)

            Spacer()
            
            HStack {
                Button {
                    onSubmit(true)
                } label: {
                    Text("Dismiss")
//                        .foregroundColor(Color(.systemBackground))
                        .padding()
//                        .background(Color.primary)
                        .cornerRadius(100)
                }
                Spacer()
                Button(action: {
                    sendThresholdHandler(action: "add", appDelegate: appDelegate, thresholdPrice: thresholdPrice, comparison: comparison, muteDuration: selectedLimit.rawValue)
                }) {
                    Text("Set Alert")
                        .foregroundColor(Color(.systemBackground))
                        .padding()
                        .background(Color.primary)
                        .cornerRadius(100)
                }.opacity(thresholdPrice.count > 0 ? 1 : 0.5)
                
            }
            
        }
        .frame(height: 400)
        .onAppear {
            focusedField = true
        }
        .onChange(of: thresholdPrice, perform: {newThresholdPrice in
            if (newThresholdPrice.count == 0) {
                displayComparison = "LOWER/HIGHER"
                displayComparisonColor = Color.blue
            } else {
                if (Float(newThresholdPrice) ?? 0 < Float(avg) ?? 0) {
                    comparison = "less_than_or_equal_to"
                    displayComparison = "LOWER"
                    displayComparisonColor = Color.green
                }
                if (Float(newThresholdPrice) ?? 0 > Float(avg) ?? 0) {
                    comparison = "greater_than"
                    displayComparison = "HIGHER"
                    displayComparisonColor = Color.red
                }
            }
        })
    }
    
    func askForReview() {
        let twoWeeks = 14 * 24 * 60 * 60.0
        let currentTime = Date.now.timeIntervalSince1970
        
        if (requestReviewTimestamp + twoWeeks < currentTime) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                requestReview()
                requestReviewTimestamp = Date.now.timeIntervalSince1970
            }
        }
    }
    
    func sendThresholdHandler(action: String, appDelegate: AppDelegate, thresholdPrice: String, comparison: String, muteDuration: Int) {
        if let deviceToken = appDelegate.deviceToken {
            sendThresholdPrice(
                action: action,
                deviceToken: deviceToken,
                threshold: thresholdPrice,
                comparison: comparison,
                mute_duration: muteDuration
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let newThresholds):
                        DispatchQueue.main.async {
                            self.thresholds.append(newThresholds.last!)
                        }
                        onSubmit(true)
                        askForReview()
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
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ThresholdInputView_Previews: PreviewProvider {
    static var previews: some View {
        ThresholdInputView(onSubmit: {result in
            print(result)
        })
    }
}


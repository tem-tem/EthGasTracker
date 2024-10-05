//
//  ReferralInputSheet.swift
//  EthGasTracker
//
//  Created by Tem on 10/3/24.
//

import SwiftUI
import Combine
import AlertToast

struct ReferralInputSheet: View {
    @Binding var inputCode: String
    var onSubmit: () -> Void
    var onCancel: () -> Void = {}
    
    @State private var showClownToast = false

    var body: some View {
        VStack(spacing: 0) {
            Text("Enter referral code")
            HStack {
                Spacer()
                TextField("ABC123", text: $inputCode)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .keyboardType(.asciiCapable)
                    .autocorrectionDisabled(true)
                    .onReceive(Just(inputCode.count)) { count in
                        if count > 6 {
                            inputCode = String(inputCode.prefix(6))
                        } else {
                            inputCode = inputCode.uppercased()
                        }
                    }
                    .frame(width: 200)
                    .font(.system(.title, design: .monospaced, weight: .semibold))
                    .multilineTextAlignment(.center)
                    
                Spacer()
            }

            Button("Submit", action: {
                if inputCode == "ABC123" {
                    showClownToast = true
                    return
                }
                onSubmit()
            })
                .padding()
                .buttonStyle(.borderedProminent)
                .disabled(inputCode.count < 6)
            Button("Cancel", role: .cancel) {
                onCancel()
            }
        }
        .onAppear {
            inputCode = ""
        }
        .toast(isPresenting: $showClownToast, duration: 2) {
            AlertToast(type: .regular, title: "🤡🤡🤡🤣😂🥵🤡")
        }
        .padding()
    }
}

#Preview {
    PreviewWrapper {
        ReferralInputSheet(inputCode: .constant(""), onSubmit: {})
    }
}

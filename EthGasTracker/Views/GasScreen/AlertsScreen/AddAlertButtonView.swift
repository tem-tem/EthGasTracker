//
//  AddAlertButtonView.swift
//  EthGasTracker
//
//  Created by Tem on 10/13/24.
//

import SwiftUI

struct AddAlertButtonView: View {
    @Binding var showingAlertForm: Bool
    @State var showInstructions = false
    @State var showRestartInstructions = false
    
    var body: some View {
        Button {
            // Request notification permission before showing the alert form
            NotificationPermissionManager.shared.requestNotificationPermission { granted in
                if granted {
                    // check device token and set it
                    if let deviceToken = DeviceTokenManager.shared.deviceToken {
//                        print("Device token already set: \(deviceToken)")
                        // If permission is granted, show the alert form
                        DispatchQueue.main.async {
                            showingAlertForm = true
                        }
                    } else {
//                        print("Device token not set.")
                        showRestartInstructions = true
                    }
                } else {
//                    print("Notification permission not granted.")
                    showInstructions = true
                    // Optionally, show an alert or handle the case where permission is denied
                }
            }
        } label: {
            BorderedText(value: "Add Alert")
        }
        .sheet(isPresented: $showInstructions) {
            InstructionsView()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showRestartInstructions) {
            RestartInstructionsView()
                .presentationDetents([.medium])
        }
    }
}



struct InstructionsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("This feature requires notification permissions.")
                .font(.title)
                .bold()
                .padding(.bottom)
            Text("Please allow notifications in the Settings and restart the app.")
                .multilineTextAlignment(.leading)
            Spacer()
            HStack {
                Spacer()
                Button {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } label: {
                    BorderedText(value: "Open Settings")
                }
                Spacer()
            }
            Spacer()
//            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct RestartInstructionsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Please restart the app.")
                .font(.title)
                .bold()
                .padding(.bottom)
            Text("Notification permissions have been granted, please restart the app for the changes to take effect.")
                .multilineTextAlignment(.leading)
        }
        .padding()
    }
}

//
//  NotificationView.swift
//  EthGasTracker
//
//  Created by Tem on 4/14/23.
//
import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @ThresholdsStorage(key: "thresholds") var thresholds: [Threshold] = []
    @State private var deleting = false
    
    var body: some View {
        VStack {
            if (thresholds.count > 0) {
                HStack {
                    Text("Notifications").bold()
                    Spacer()
                    Button(deleting ? "Done" : "Delete") {
                        deleting.toggle()
                    }
                }
                Divider()
                ThresholdListView(deleting: $deleting)
            }
        }
        .onChange(of: thresholds.count) { count in
            if count == 0 {
                deleting = false
            }
        }
    }
}

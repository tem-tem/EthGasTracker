//
//  FetchingStatusBar.swift
//  EthGasTracker
//
//  Created by Tem on 2/16/24.
//
import SwiftUI

struct FetchingStatusBar: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @State private var progress = 1.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var status: Status {
        liveDataVM.status
    }

    var body: some View {
        HStack {
            if status == .fetching {
                ProgressView()
                Spacer()
            } else if status == .ok {
                ProgressView(value: progress)
                    .onAppear() {
                        progress = 1.0
                        withAnimation(.easeOut(duration: FETCH_INTERVAL)) {
                            progress = 0
                        }
                    }
            } else if status == .error {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            } else if status == .offline {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .onAppear {
            if status == .ok {
                progress = 1.0 // Reset progress when view appears
            }
        }
    }
}


#Preview {
    FetchingStatusBar()
}

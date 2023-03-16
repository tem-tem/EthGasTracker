//
//  ContentView.swift
//  EthGasTracker
//
//  Created by Tem on 3/11/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scene
    @AppStorage("lastUpdate") var lastUpdate: Double = 0
    @AppStorage("timestamp") var timestamp: Double = 0
    @State private var isFresh = true
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
    
    var body: some View {
        VStack {
            StatusBar()
                .padding(.bottom, 10)
            GasView()
                .opacity(isFresh ? 1 : 0.6)
                .saturation(isFresh ? 1 : 0)
                .animation(.easeInOut(duration: isFresh ? 0.1 : 0.5), value: isFresh)
            Spacer()
            Text("Captured on \(formattedTimestamp)").font(.caption).foregroundColor(.gray)
        }
        .padding(20)
        .onAppear {
            self.isFresh = lessThan15secondsAgo(lastUpdate)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .default).autoconnect()) { _ in
            self.isFresh = lessThan15secondsAgo(lastUpdate)
        }
        .onChange(of: scene) { newValue in
            switch newValue {
            case .active:
                self.isFresh = lessThan15secondsAgo(lastUpdate)
            default:
                break
            }
        }
    }
    
    func lessThan15secondsAgo(_ stamp: Double) -> Bool {
        return Date(timeIntervalSince1970: TimeInterval(stamp)) > Date(timeIntervalSinceNow: -15)
    }
}

//
//  ContentView.swift
//  EthGasTracker
//
//  Created by Tem on 3/11/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scene
    @AppStorage("timestamp") var timestamp: Double = 0
    @State private var isFresh = true
    @State private var showingSheet = false
    @ThresholdsStorage(key: "thresholds") var thresholds: [Threshold] = []
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    PlainGasView()
                        .opacity(isFresh ? 1 : 0.6)
                        .saturation(isFresh ? 1 : 0)
                        .animation(.easeInOut(duration: isFresh ? 0.1 : 0.5), value: isFresh)
                        .padding(.horizontal, 10)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Captured on \(formattedTimestamp)")
                                .font(.caption)
//                                .padding(.top, 40)
                            StatusBar()
                                .padding(.bottom, 50)
                        }
                        Spacer()
                    }
                        .padding(.horizontal, 10)
                    NotificationView().padding(10)
                }
            }
            .onReceive(Timer.publish(every: 10, on: .main, in: .default).autoconnect()) { _ in
                self.isFresh = lessThan60secondsAgo(timestamp)
            }
            .onChange(of: scene) { newValue in
                switch newValue {
                case .active:
                    self.isFresh = true
                default:
                    break
                }
            }
            .onChange(of: timestamp) { _ in
                simpleSuccess()
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    if (thresholds.count == 0) {
                        Button(action: {
                            showingSheet.toggle()
                        }) {
                            Text("Add Notification").bold()
                        }
                        .sheet(isPresented: $showingSheet) {
                            ThresholdInputView(onSubmit: {result in
                                showingSheet = !result
                            }).padding(20)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground), Color(.systemBackground).opacity(0)]),
                    startPoint: .bottom,
                    endPoint: .top))
            }
            
        }
    }
    
    func lessThan60secondsAgo(_ stamp: Double) -> Bool {
        return Date(timeIntervalSince1970: TimeInterval(stamp)) > Date(timeIntervalSinceNow: -60)
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

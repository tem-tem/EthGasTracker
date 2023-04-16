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
    @State private var showingSheet = false
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    PlainGasView()
                        .opacity(isFresh ? 1 : 0.6)
                        .saturation(isFresh ? 1 : 0)
                        .animation(.easeInOut(duration: isFresh ? 0.1 : 0.5), value: isFresh)
                        .padding(10)
                    StatusBar()
                        .padding(.bottom, 10)
                    Text("Captured on \(formattedTimestamp)").font(.caption).foregroundColor(.gray)
                        .padding(.bottom, 50)
    //                Spacer()
                    NotificationView().padding(10)
    //                Spacer()
                }
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
            .onChange(of: lastUpdate) { _ in
                simpleSuccess()
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
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
    
    func lessThan15secondsAgo(_ stamp: Double) -> Bool {
        return Date(timeIntervalSince1970: TimeInterval(stamp)) > Date(timeIntervalSinceNow: -15)
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

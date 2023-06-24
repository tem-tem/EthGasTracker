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
    @State private var showingSettings = false
    @State private var showingHeatmap = false
    @State private var showingChangelog = false
    @ThresholdsStorage(key: "thresholds") var thresholds: [Threshold] = []
    
    @AppStorage("settings.hapticFeedback") private var hapticFeedback = true
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack {
                        VStack {
                            Text("Gas")
                                .font(.largeTitle).bold()
                                .padding(.bottom, -10)
                                .padding(.top, -15)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            StatusBar()
                            Text("\(formattedTimestamp)")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 5)
                    Divider()
                        .padding(.bottom, 5)
                    PlainGasView()
                        .opacity(isFresh ? 1 : 0.6)
                        .saturation(isFresh ? 1 : 0)
                        .animation(.easeInOut(duration: isFresh ? 0.1 : 0.5), value: isFresh)
                        .padding(.horizontal, 10)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Last 48 hours").font(.title2).bold()
                            
                            Spacer()
                            
                            Button(action: {
                                showingHeatmap.toggle()
                            }) {
                                Text("More").bold()
                            }
                            .sheet(isPresented: $showingHeatmap) {
                                HeatMapView(isPresented: $showingHeatmap)
                                .padding(10)
                            }
                        }
                        Divider()
                        ScrollViewReader { scrollProxy in
                            ScrollView(.horizontal) {
                                BarsChart()
                                    .frame(height: 200)
                                    .padding(.bottom, 20)
                                    .id("barChart")
                            }
                            .onAppear {
                                scrollToTheEnd(using: scrollProxy, id: "barChart")
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                    
//                    MessagesView()
//                        .cornerRadius(15)
//                        .frame(height: 100)
//                        .padding(10)
                    
                    NotificationView()
                        .padding(10)
                        .padding(.bottom, 100)
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
            .onChange(of: timestamp) { newTimestamp in
                if (hapticFeedback) {
                    runHapticFeedback()
                }
                self.isFresh = lessThan60secondsAgo(newTimestamp)
            }
            
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        showingChangelog.toggle()
                    }) {
                        VStack {
                            Image(systemName: "sparkles")
//                            Text("Changelog").font(.caption)
                        }
//                        Image(systemName: "lineweight")
//                            .frame(width: 20, height: 20)
                            .padding(10)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .sheet(isPresented: $showingChangelog) {
                        ChangelogView()
                    }
                    Spacer()
                    if (thresholds.count < 3) {
                        Button(action: {
                            showingSheet.toggle()
                        }) {
                            VStack {
                                Image(systemName: "bell.badge")
                                Text("Set Notification").font(.caption)
                            }
//                            Text("Add Notification").bold()
//                                .frame(height: 20)
                                .padding(10)
                                .padding(.horizontal, 20)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                                .shadow(color: .black.opacity(0.1), radius: 15, y: 2)
                        }
                        .sheet(isPresented: $showingSheet) {
                            ThresholdInputView(onSubmit: {result in
                                showingSheet = !result
                            }).padding(20)
                        }
                    }
                    Spacer()
                    Button(action: {
                        showingSettings.toggle()
                    }) {
                        VStack {
                            Image(systemName: "gear")
//                            Text("Settings").font(.caption)
                        }
//                        Image(systemName: "gear")
//                            .frame(width: 20, height: 20)
                            .padding(10)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
//                    .border(.red)
                    .sheet(isPresented: $showingSettings) {
                        SettingsView(isPresented: $showingSettings)
                            .presentationDetents([.large])
                    }
                }
                .padding(10)
                .padding(.bottom, 20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 0))
            }
            .ignoresSafeArea()
            
        }
    }
    
    func lessThan60secondsAgo(_ stamp: Double) -> Bool {
        return Date(timeIntervalSince1970: TimeInterval(stamp)) > Date(timeIntervalSinceNow: -60)
    }
    
    func runHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func scrollToTheEnd(using scrollProxy: ScrollViewProxy, id: String) {
        withAnimation {
            scrollProxy.scrollTo(id, anchor: .trailing)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

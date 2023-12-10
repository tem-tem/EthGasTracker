//
//  MainFocusView.swift
//  EthGasTracker
//
//  Created by Tem on 8/20/23.
//

import SwiftUI

struct MainFocusView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var selectedDate: Date? = nil
    @State private var selectedPrice: Float? = nil
    @State private var selectedKey: String? = nil
    @State private var showAlertsSheet = false
    @State private var showFullActionList = false
    @State private var showingGuide = false
    @AppStorage(SettingsKeys().hapticFeedbackEnabled) private var haptic = true
    let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack {
            //            RadialGradient(colors: [.accentColor.opacity(1), .accentColor.opacity(0)],
            //                                  center: .top,
            //                                  startRadius: 0,
            //                                  endRadius: 500)
            //                .ignoresSafeArea()
            VStack {
                EthPriceView(
                    selectedKey: $selectedKey,
                    selectedDate: $selectedDate
                )
                .padding(.horizontal)
                .padding(.vertical, 3)
                .font(.caption)
                .opacity(0.8)
//                Divider()
                ServerMessages(messages: appDelegate.serverMessages)
                    .padding(.horizontal)
                    .frame(height: 50)
                    .opacity(selectedPrice != nil ? 0 : 1)
                    .overlay(
                        TimeAgoView(selectedDate: $selectedDate)
                     )
                GasIndexFocus(selectedDate: $selectedDate, selectedPrice: $selectedPrice)
//                    .padding(.top, 10)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                    .onTapGesture {
                        showingGuide = true
                    }
                    .sheet(isPresented: $showingGuide) {
                        GasLevelExplainerView()
                    }
                //                ScrollView {
                //                    ActionsListFocusView(actions: appDelegate.actions,
                //                                         selectedKey: $selectedKey)
                //                }
                //                .frame(minHeight: 250)
                //                .padding(.horizontal)
                ActionsGridView(selectedKey: $selectedKey, actions: appDelegate.defaultActions)
                    .padding(.horizontal)
                
                Button {
                    showFullActionList = true
                } label: {
                    HStack {
                        Spacer()
                        Text("More Actions")
                            .padding(10)
                        Spacer()
                    }
//                    .background(.ultraThinMaterial)
                }
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay( /// apply a rounded border
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(appDelegate.gasLevel.color.opacity(0.3), lineWidth: 1)
                )
                //                .foregroundStyle(Color("BG"))
                .sheet(isPresented: $showFullActionList) {
                    ActionsListFocusView(
                        actions: appDelegate.actions,
                        selectedKey: $selectedKey
                    )
                    .padding()
                }
                //                .id(addId)
                .padding()
                .padding(.bottom)
                Spacer()
                //                .padding()
                GasIndexChartFocus(
                    entries: appDelegate.gasIndexEntries,
                    min: appDelegate.gasIndexEntriesMinMax.min,
                    max: appDelegate.gasIndexEntriesMinMax.max,
                    selectedDate: $selectedDate,
                    selectedPrice: $selectedPrice,
                    selectedKey: $selectedKey
                )
                //                .frame(height: 100)
                //                Spacer()
                
            }
            .onChange(of: selectedKey) { _ in
                if (haptic) {
                    hapticFeedbackGenerator.impactOccurred()
                }
            }
        }
    }
}

struct MainFocusView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            MainFocusView()
        }
    }
}

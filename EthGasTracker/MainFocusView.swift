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
    let hapticFeedbackGeneratorHeavy = UIImpactFeedbackGenerator(style: .heavy)
    @State private var activeChartType = ChartTypes.live
    @State private var selectedHistoricalData: HistoricalData? = nil
    
    var isActiveSelection: Bool {
        return selectedPrice != nil || selectedHistoricalData != nil
    }
    
    var body: some View {
        ZStack {
            VStack {
                EthPriceView(
                    selectedKey: $selectedKey,
                    selectedDate: $selectedDate,
                    selectedHistoricalData: $selectedHistoricalData,
                    isActiveSelection: isActiveSelection
                )
                .padding(.horizontal)
                .padding(.vertical, 3)
                .font(.caption)
                .opacity(0.8)
//                Divider()
                ServerMessages(messages: appDelegate.serverMessages)
                    .padding(.horizontal)
                    .frame(height: 50)
                    .opacity(isActiveSelection ? 0 : 1)
                    .overlay(
                        TimeAgoView(selectedDate: $selectedDate, selectedHistoricalData: $selectedHistoricalData)
                     )
                GasIndexFocus(selectedDate: $selectedDate, selectedPrice: $selectedPrice, selectedHistoricalData: $selectedHistoricalData, isActiveSelection: isActiveSelection, activeChartType: activeChartType)
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
                
                ActionsGridView(selectedKey: $selectedKey, actions: appDelegate.defaultActions, selectedHistoricalData: $selectedHistoricalData, isActiveSelection: isActiveSelection)
                    .padding(.horizontal)
                
                HStack {
                    Button {
                        showFullActionList = true
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.up")
                            Text("Show more actions")
//                            Text("All")
//                                .padding(10)
//                            Spacer()
                        }.font(.caption)
                        .padding(.top, 5)
                        .padding(.trailing, 5)
    //                    .background(.ultraThinMaterial)
                    }
//                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .sheet(isPresented: $showFullActionList) {
                        ActionsListFocusView(
                            actions: appDelegate.actions,
                            selectedKey: $selectedKey
                        )
                        .padding()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
//                Divider()
               
                GasIndexWithPicker(selectedDate: $selectedDate, selectedPrice: $selectedPrice, selectedKey: $selectedKey, selectedHistoricalData: $selectedHistoricalData, activeChartType: $activeChartType)
                
                
            }
            .onChange(of: selectedKey) { _ in
                if (haptic) {
                    hapticFeedbackGenerator.impactOccurred()
                }
            }
            .onChange(of: selectedHistoricalData) { _ in
                if (haptic) {
                    hapticFeedbackGenerator.impactOccurred()
                }
            }
            .onChange(of: activeChartType) { _ in
                if (haptic) {
                    hapticFeedbackGeneratorHeavy.impactOccurred()
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

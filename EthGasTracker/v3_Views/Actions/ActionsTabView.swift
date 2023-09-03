//
//  ActionsTabView.swift
//  EthGasTracker
//
//  Created by Tem on 8/10/23.
//

import SwiftUI

struct ActionsTabView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @AppStorage("isStale") var isStale = false
    
    private let gradient: [Color] = [Color("avg"), Color("avgLight"), Color("avg")]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    ActionPriceListView(actions: appDelegate.actions)
                    .opacity(isStale ? 0.6 : 1)
                    .saturation(isStale ? 0 : 1)
                    .animation(.easeInOut(duration: isStale ? 0.5 : 0.1), value: isStale)
                    .padding(.bottom, 25)
                    .padding()
                }
                VStack {
                    Spacer()
                    
//                    Button {
//                        print("tapped")
//                    } label: {
//                        HStack {
//                            Spacer()
//                            Text("Unlock all actions")
//                                .bold()
//                                .padding(.vertical, 5)
//                            Spacer()
//                        }
//                    }
//                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }.navigationTitle("Actions")
        }
    }
}

struct ActionsTabView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            ActionsTabView()
        }
    }
}

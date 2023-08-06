//
//  MainView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    EthPriceView().padding()
                    Text("Gas")
                    LegacyGasPriceView().padding()
                    GasPriceView().padding()
                    Text("On-chain Action Fees")
                    ActionPriceListView().padding()
                }
                
            }
            VStack {
                Spacer()
                MenuBarView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

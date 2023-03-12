//
//  ContentView.swift
//  EthGasTracker
//
//  Created by Tem on 3/11/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            FetchStatusView().padding(.bottom, 20)
            GasView()
            Spacer()
        }
        .padding(20)
//        .border(.black)
//        .padding(30)
    }
}

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
            GasView()
            Spacer()
            FetchStatusView()
        }
        .padding(20)
//        .border(.black)
//        .padding(30)
    }
}

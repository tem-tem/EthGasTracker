//
//  ContentView.swift
//  EthGasTrackerWatch Watch App
//
//  Created by Tem on 2/15/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    var body: some View {
//        GasCardView()
        HStack {
            GasIndexView(
                value: gas,
                color: liveDataVM.gasLevel.color
            )
            .offset(x: isCollapsed ? -70 : 0)
            .scaleEffect(isCollapsed ? 0.4 : 1)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

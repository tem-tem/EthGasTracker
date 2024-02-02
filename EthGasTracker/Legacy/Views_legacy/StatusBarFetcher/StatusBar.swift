//
//  StatusBar.swift
//  EthGasTracker
//
//  Created by Tem on 3/15/23.
//

import SwiftUI

struct StatusBar: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        HStack (alignment: .center) {
            FetchView()
        }
    }
}

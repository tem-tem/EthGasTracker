//
//  MainBtcView.swift
//  EthGasTracker
//
//  Created by Tem on 2/19/24.
//

import SwiftUI
import Charts

struct MainBtcView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    
    var price: Double {
        liveDataVM.btcDataEntity.price
    }
    
    var body: some View {
        VStack {
            BtcMempool()
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
            BtcCardView()
                .padding(.horizontal, 5)
        }
    }
}

#Preview {
    PreviewWrapper {
        MainBtcView()
            .padding()
            .background(Color("BG.L0"))
    }
}

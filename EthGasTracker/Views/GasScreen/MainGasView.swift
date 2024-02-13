//
//  MainGasView.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import SwiftUI

struct MainGasView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    @EnvironmentObject var customActionDM: CustomActionDataManager
    
    @State private var isCollapsed = false
    
    var body: some View {
        VStack(spacing: 0) {
            if !isCollapsed {
                ActionsBlockDenseView(
                    actions: customActionDM.pinnedActions,
                    gas: activeSelectionVM.gas ?? liveDataVM.gasLevel.currentGas,
                    ethPrice: activeSelectionVM.ethPrice ?? liveDataVM.ethPrice
                )
                    .padding(.vertical)
                    .padding(.horizontal, 5)
            }
            if isCollapsed {
                ActionsManagerView()
            }
            GasCardView(isCollapsed: $isCollapsed)
        }
    }
}

#Preview {
    PreviewWrapper {
        MainGasView()
            .background(Color("BG.L0"))
    }
}

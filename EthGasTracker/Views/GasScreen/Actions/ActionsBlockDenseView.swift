//
//  ActionsXLDense.swift
//  EthGasTracker
//
//  Created by Tem on 1/20/24.
//

import SwiftUI

struct ActionsBlockDenseView: View {
    var actions: [CustomActionEntity]
    var gas: Double
    var ethPrice: Double
    var columns: Int = 3
    var amount: Int = 9
    
    var cols: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 2), count: columns)
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(actions.prefix(amount)) { action in
                    var value: Double {
                        CustomActionEntity.calcCost(for: Double(action.limit), ethPrice: ethPrice, gas: gas)
                    }
                    HStack {
                        ActionSMView(
                            name: action.name ?? "",
                            groupName: action.group ?? "",
                            value: value,
    //                        accentColor: Color.primary,
                            primaryColor: Color.primary,
                            secondaryColor: Color.secondary
                        )
                        Spacer()
                    }
                }
            }
        }
    }
}

//#Preview {
//    ActionsBlockDenseView(
//        actions: LiveDataVM(apiManager: APIManager(), customActionDM: CustomActionDataManager()).actions
//    )
//}

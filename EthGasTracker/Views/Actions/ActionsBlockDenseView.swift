//
//  ActionsXLDense.swift
//  EthGasTracker
//
//  Created by Tem on 1/20/24.
//

import SwiftUI

struct ActionsBlockDenseView: View {
//    @EnvironmentObject var liveDataVM: LiveDataVM
//    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
//    var defaultActions: [ActionEntity] {
//        return liveDataVM.actions.filter { $0.metadata.pinned }
//    }
    
    var actions: [ActionEntity]
    var selectedIndex: Int? = nil
    var selectedHistoricalData: HistoricalData? = nil
    var columns: Int = 3
    var amount: Int = 9
    
    var sortedActions: [ActionEntity] {
        let actions = actions.sorted {
            switch ($0.metadata.pinned, $1.metadata.pinned) {
            case (true, false):
                return true
            case (false, true):
                return false
            default:
                return false // or some other logic for items with equal pinned status
            }
        }
        
        if actions.count > amount {
            return Array(actions[0..<amount])
        } else {
            return actions
        }
    }
    
    var cols: [GridItem] {
//        return columns amount of GridItem(.flexible(), spacing: 2)
        return Array(repeating: GridItem(.flexible(), spacing: 2), count: columns)
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(sortedActions, id: \.metadata.key) { action in
                    var value: Double {
                        if let index = selectedIndex {
                            return action.entries[index].normal
                        } else if let historicalData = selectedHistoricalData {
                            return ActionEntity.calcCost(for: action.metadata.limit, ethPrice: historicalData.price, gas: historicalData.avg)
                        }
                        return action.entries.last?.normal ?? 0
                    }
                    HStack {
                        ActionSMView(
                            name: action.metadata.name,
                            groupName: action.metadata.groupName,
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

#Preview {
    ActionsBlockDenseView(
        actions: LiveDataVM(apiManager: APIManager()).actions
    )
//        .environmentObject(LiveDataVM(apiManager: APIManager()))
//        .environmentObject(ActiveSelectionVM())
//        .environmentObject(HistoricalDataVM(apiManager: APIManager()))
//        .environmentObject(StoreVM())
}

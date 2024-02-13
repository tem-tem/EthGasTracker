//
//  ActionsBlockView.swift
//  EthGasTracker
//
//  Created by Tem on 1/17/24.
//

import SwiftUI

struct ActionsBlockView: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
//    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
//    @AppStorage("currency") var currency: String = "USD"
//    var currencyCode: String {
//        return getSymbol(forCurrencyCode: currency) ?? currency
//    }
    var defaultActions: [ActionEntity] {
        return liveDataVM.actions.filter { $0.metadata.pinned }
    }
    
    var actions: [ActionEntity] {
        return liveDataVM.actions.filter { !$0.metadata.pinned }
    }
    
    let cols = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        VStack {
            LazyVGrid(columns: cols, spacing: 2) {
                ForEach(defaultActions, id: \.metadata.key) { action in
                    ActionXLView(
                        name: action.metadata.name,
                        groupName: action.metadata.groupName,
                        value: action.entries.last?.normal ?? 0.0,
                        accentColor: Color.primary,
                        primaryColor: Color.primary,
                        secondaryColor: Color.secondary
                    )
                }
            }
        }
    }
}

#Preview {
    PreviewWrapper {
        ActionsBlockView()
    }
}

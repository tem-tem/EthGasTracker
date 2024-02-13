//
//  ActionsScrollView.swift
//  EthGasTracker
//
//  Created by Tem on 1/18/24.
//

import SwiftUI

struct ActionsScrollView: View {
    let primaryColor: Color
    let secondaryColor: Color
    @EnvironmentObject var liveDataVM: LiveDataVM
    
    var actions: [ActionEntity] {
        return liveDataVM.actions.filter { !$0.metadata.pinned }
    }
    var body: some View {
        if (actions.count > 0) {
            let width: CGFloat = 150
            InfiniteScroller(contentWidth: CGFloat(actions.count) * width, duration: 60) {
                HStack(spacing: 0) {
                    ForEach(actions, id: \.metadata.key) { action in
                        ActionSMView(
                            name: action.metadata.name,
                            groupName: action.metadata.groupName,
                            value: action.entries.last?.normal ?? 0.0,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor
                        )
                        .frame(width: width)
                    }
                }
            }
        }
    }
}

#Preview {
    PreviewWrapper {
        ActionsScrollView(primaryColor: .primary, secondaryColor: .secondary)
    }
}

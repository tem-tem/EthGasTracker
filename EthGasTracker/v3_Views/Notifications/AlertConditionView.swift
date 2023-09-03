//
//  AlertConditionView.swift
//  EthGasTracker
//
//  Created by Tem on 8/15/23.
//

import SwiftUI

extension GasAlert.Condition.Comparison {
    var humanReadable: String {
        switch self {
        case .greater_than: return "<"
        case .greater_than_or_equal: return "≤"
        case .less_than: return "<"
        case .less_than_or_equal: return "≤"
        }
    }
}


struct AlertConditionView: View {
    var conditions: [GasAlert.Condition]
    
    var body: some View {
        ForEach(conditions, id: \.comparison) { condition in
            if condition.value != 0 {
                HStack {
                    if (condition.comparison == .greater_than || condition.comparison == .greater_than_or_equal) {
                        Image(systemName: "arrow.up")
                            .foregroundColor(Color(.systemRed))
                    } else {
                        Image(systemName: "arrow.down")
                            .foregroundColor(Color.accentColor)
                    }
                    Text("\(condition.value)")
//
//                    if (condition.comparison == .greater_than || condition.comparison == .greater_than_or_equal) {
//                        Text("\(condition.value) ") +
//                        Text("\(condition.comparison.humanReadable)").foregroundColor(Color.secondary)
//                        Image(systemName: "flame")
//                            .foregroundColor(Color.secondary)
//                    } else {
//                        Image(systemName: "flame")
//                            .foregroundColor(Color.secondary)
//                        Text("\(condition.comparison.humanReadable)").foregroundColor(Color.secondary) +
//                        Text(" \(condition.value)")
//                    }
                }
                    .font(.title)
                    .bold()
            }
        }
    }
}

struct AlertConditionView_Previews: PreviewProvider {
    static var previews: some View {
        AlertConditionView(conditions: [GasAlert.Condition(comparison: .greater_than, value: 100)])
    }
}

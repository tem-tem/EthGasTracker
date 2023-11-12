//
//  DiffValueView.swift
//  EthGasTracker
//
//  Created by Tem on 9/5/23.
//

import SwiftUI

struct DiffValueView: View {
    let baseValue: Float
    let targetValue: Float?
    
    var diff: Float {
        guard let target = targetValue else {
            return 0
        }
        return baseValue - target
    }
    
    var body: some View {
        if diff != 0 {
            HStack {
                if (diff > 0) {
                    Image(systemName: "arrow.down")
                } else {
                    Image(systemName: "arrow.up")
                }
                Text(String(format: "$%.2f", abs(diff)))
            }
            .opacity(0.5)
        }
    }
}

struct DiffValueView_Previews: PreviewProvider {
    static var previews: some View {
        DiffValueView(
            baseValue: 0, targetValue: 12
        )
    }
}

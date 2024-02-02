//
//  BorderedText.swift
//  EthGasTracker
//
//  Created by Tem on 1/25/24.
//

import SwiftUI

struct BorderedText: View {
    var value: String
    @EnvironmentObject var liveDataVM: LiveDataVM
    
    var body: some View {
        Text(value)
            .foregroundStyle(liveDataVM.gasLevel.color)
            .padding(.horizontal, 15)
            .padding(.vertical, 6)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .circular)
                    .strokeBorder(liveDataVM.gasLevel.color, lineWidth: 1)
            }
    }
}

#Preview {
    BorderedText(value: "Slow")
}

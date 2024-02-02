//
//  ActionSMView.swift
//  EthGasTracker
//
//  Created by Tem on 1/17/24.
//

import SwiftUI

struct ActionSMView: View {
    var name: String
    var groupName: String
    var value: Double
    let primaryColor: Color
    let secondaryColor: Color
    
    var body: some View {
        
        HStack(alignment: .top) {
            Rectangle()
                .frame(width: dotW, height: dotH)
                .foregroundStyle(secondaryColor)
                .opacity(dotOpacity)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 0) {
                Text(name).font(.caption2).foregroundStyle(primaryColor)
                PriceNumberView(value: value)
                    .font(.system(.caption2, design: .monospaced, weight: .bold))
                    .foregroundStyle(primaryColor)
//                .bold()
                .padding(.bottom, 3)
                Text(groupName)
                    .font(.system(.caption2, design: .monospaced, weight: .thin))
                    .foregroundStyle(secondaryColor)
            }
        }
    }
}

#Preview {
    ActionSMView(
        name: "STARKNET",
        groupName: "Native Bridges",
        value: 12.34,
        primaryColor: .primary, secondaryColor: .secondary
    )
}

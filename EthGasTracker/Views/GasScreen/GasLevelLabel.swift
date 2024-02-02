//
//  GasLevelLabel.swift
//  EthGasTracker
//
//  Created by Tem on 1/19/24.
//

import SwiftUI

struct GasLevelLabel: View {
    let label: String
    let color: Color
    let level: Int
    
    var body: some View {
//        HStack (spacing: 0) {
//            Spacer()
//            Text("\(label)")
//                .font(.system(.caption, design: .monospaced))
//                .foregroundStyle(Color(.systemBackground))
//                .padding(.horizontal, 6)
//                .padding(.vertical, 6)
//                .frame(height: 16)
//                .bold()
//        }.frame(width: 100).background(color)
        
        Text("\(label)")
            .font(.system(.caption, design: .monospaced))
//            .foregroundStyle(Color(.systemBackground))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .frame(height: 16)
            .bold()
//            .background(color)
    }
}

#Preview {
    GasLevelLabel(label: "Safe", color: .green, level: 2)
}

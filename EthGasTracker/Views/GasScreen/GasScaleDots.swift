//
//  File.swift
//  EthGasTracker
//
//  Created by Tem on 11/11/23.
//

import SwiftUI

struct GasScaleDots: View {
    let gasLevel: GasLevel
    
    var body: some View {
        HStack (spacing: 2) {
            ForEach((0..<11), id: \.self) { index in
                HStack(spacing: 5) {
                    let isActive = index <= gasLevel.level

                    Rectangle()
                        .fill(isActive ? gasLevel.color : Color.primary.opacity(0.1))
                        .frame(width: 4, height: 4)
                        .cornerRadius(5)
//                        .shadow(color: isActive ? gasLevel.color : Color.primary.opacity(0.1), radius: 4)
                }
            }
        }
    }
}

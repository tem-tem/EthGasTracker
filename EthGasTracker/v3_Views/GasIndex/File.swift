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
        VStack (alignment: .trailing, spacing: 2) {
            ForEach((0..<11).reversed(), id: \.self) { index in
                HStack {
                    let isActive = index <= gasLevel.level

                    Rectangle()
                        .fill(isActive ? gasLevel.color : Color.primary.opacity(0.1))
                        .frame(width: 5, height: 5)
                        .cornerRadius(5)
                        .shadow(color: isActive ? gasLevel.color : Color.primary.opacity(0.1), radius: 4)
                }
            }
        }
    }
}

//
//  GasIndexView.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import SwiftUI


struct GasIndexView: View {
    var value: Double
    var color: Color
    
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    
    var selectedGas: Double? {
        if let gas = activeSelectionVM.gas {
            return gas
        }
        if let gas = activeSelectionVM.historicalData?.avg {
            return gas
        }
        return nil
    }
    
    var gas: Double {
        selectedGas ?? value
    }
    
    var isActiveSelection: Bool {
        return selectedGas != nil
    }
    
    var amountOfDigints: CGFloat {
        return CGFloat(String(Int(gas)).count)
    }
    
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            Text(String(format: "%.f", round(gas)))
                .foregroundStyle(isActiveSelection ? .primary : color)
                .lineLimit(1)
                .font(.system(size: isActiveSelection ? 120 : 180, weight: isActiveSelection ? .thin : .semibold, design: .default))
                .minimumScaleFactor(0.5)
        }
//        .frame(width: 40 * amountOfDigints)
//        .padding(.horizontal, 10)
//        .background(color)
//        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    GasIndexView(value: 52.5, color: .red)
        .environmentObject(ActiveSelectionVM())
}

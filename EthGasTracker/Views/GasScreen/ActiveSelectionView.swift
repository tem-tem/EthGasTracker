//
//  ActiveSelectionView.swift
//  EthGasTracker
//
//  Created by Tem on 1/20/24.
//

import SwiftUI

struct ActiveSelectionView: View {
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    
    var selectedGas: Int? {
        if let gas = activeSelectionVM.gas {
            return Int(gas)
        }
        if let gas = activeSelectionVM.historicalData?.avg {
            return Int(gas)
        }
        return nil
    }
    
    var date: Date? {
        if let date = activeSelectionVM.date {
            return date
        }
        if let date = activeSelectionVM.historicalData?.date {
            return date
        }
        return nil
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("\(selectedGas ?? 0)")
                    .font(.system(.largeTitle, design: .monospaced))
                Spacer()
            }
            if let date = date {
                TimestampView(timestamp: date.timeIntervalSince1970)
            }
        }
        .frame(minHeight: 115)
        .background(.white)
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .opacity(selectedGas == nil ? 0 : 1)
    }
}

#Preview {
    ActiveSelectionView()
}

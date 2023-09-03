//
//  EnableLegacyGasView.swift
//  EthGasTracker
//
//  Created by Tem on 8/9/23.
//

import SwiftUI

struct EnableLegacyGasView: View {
    @AppStorage(SettingsKeys().useEIP1559) private var useEIP1559 = true
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: useEIP1559 ? "smallcircle.filled.circle.fill" : "smallcircle.filled.circle")
                    .frame(width: 32, height: 32)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                    .foregroundColor(.white)
                Toggle("EIP-1559 Standart", isOn: $useEIP1559)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
        }
    }
}

struct EnableLegacyGasView_Previews: PreviewProvider {
    static var previews: some View {
        EnableLegacyGasView()
    }
}

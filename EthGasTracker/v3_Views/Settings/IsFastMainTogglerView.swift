//
//  IsFastMainTogglerView.swift
//  EthGasTracker
//
//  Created by Tem on 8/8/23.
//

import SwiftUI

struct IsFastMainTogglerView: View {
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: isFastMain ? "hare.fill" : "hare")
                    .frame(width: 32, height: 32)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                    .foregroundColor(.white)
                Toggle("Fast First", isOn: $isFastMain)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
        }
    }
}

struct IsFastMainTogglerView_Previews: PreviewProvider {
    static var previews: some View {
        IsFastMainTogglerView()
    }
}

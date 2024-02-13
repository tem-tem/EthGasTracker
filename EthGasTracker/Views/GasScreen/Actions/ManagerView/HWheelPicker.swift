//
//  HWheelPicker.swift
//  EthGasTracker
//
//  Created by Tem on 2/12/24.
//

import SwiftUI

struct HWheelPicker: View {
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    @State var speed: Double = 50
    @State var isEditing = false
    
    var body: some View {
        Slider(
            value: $speed,
            in: 0...100,
            step: 1,
            onEditingChanged: { editing in
                isEditing = editing
            }
        )
        .accentColor(.purple)
        .onChange(of: speed) { value in
            activeSelectionVM.gas = value
        }
        .onAppear {
            activeSelectionVM.gas = speed
        }
    }
}

#Preview {
    PreviewWrapper {
        HWheelPicker()
    }
}

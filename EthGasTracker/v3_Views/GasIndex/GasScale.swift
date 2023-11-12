//
//  GasScale.swift
//  EthGasTracker
//
//  Created by Tem on 9/5/23.
//

import SwiftUI

struct GasScale: View {
    @Binding var selectedPrice: Float?
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        GasScaleDots(gasLevel: appDelegate.gasLevel)
    }
}



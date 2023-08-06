//
//  SwiftUIView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

struct GasPriceView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    var body: some View {
        NormalFastView(name: "EIP 1559", normal: appDelegate.gas.normal, fast: appDelegate.gas.fast, currency: nil)
    }
}

struct GasPriceView_Previews: PreviewProvider {
    static var previews: some View {
        GasPriceView()
    }
}

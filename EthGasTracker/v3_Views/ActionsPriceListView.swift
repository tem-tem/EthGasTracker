//
//  ActionPriceView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

struct ActionPriceListView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    var body: some View {
        ForEach(appDelegate.actions, id: \.action) { action in
            NormalFastView(name: "ether to \(action.action)", normal: action.price.normal, fast: action.price.fast, currency: "usd")
        }
    }
}

struct ActionPriceListView_Previews: PreviewProvider {
    static var previews: some View {
        ActionPriceListView()
    }
}

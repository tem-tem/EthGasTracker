//
//  EthGasWidgetBundle.swift
//  EthGasWidget
//
//  Created by Tem on 5/15/23.
//

import WidgetKit
import SwiftUI

@main
struct EthGasWidgetBundle: WidgetBundle {
    var body: some Widget {
//        EthGasWidgetSmall()
//        EthGasWidgetMedium()
//        EthGasWidgetLarge()
//        EthGasWidgetAll()
//        EthGasWidget()
//        EthGasWidgetLow()
//        EthGasWidgetHigh()
        LockScreenWidget()
//        EthGasWidgetLiveActivity()
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

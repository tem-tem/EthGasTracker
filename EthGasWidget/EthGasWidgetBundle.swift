////
////  EthGasWidgetBundle.swift
////  EthGasWidget
////
////  Created by Tem on 5/15/23.
////

import WidgetKit
import SwiftUI

@main
struct EthGasWidgetBundle: WidgetBundle {
    var body: some Widget {
        LiveGasWidget()
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

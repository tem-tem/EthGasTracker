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
        EthGasWidget()
        EthGasWidgetLiveActivity()
    }
}

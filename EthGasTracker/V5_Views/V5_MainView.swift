//
//  V5_MainView.swift
//  EthGasTracker
//
//  Created by Tem on 10/10/24.
//

import SwiftUI

struct V5_MainView: View {
    var body: some View {
        Text("V5_MainView")
    }
}

enum SelectedScreen {
    case eth
    case alerts
}


#Preview {
    PreviewWrapper {
        V5_MainView()
    }
}

//
//  SettingsTabView.swift
//  EthGasTracker
//
//  Created by Tem on 8/11/23.
//

import SwiftUI

struct SettingsTabView: View {
    @AppStorage("userSettings.colorScheme") var settingsColorScheme: ColorScheme = .none
    @Environment(\.colorScheme) private var defaultColorScheme
    
    var body: some View {
        SettingsView()
            .preferredColorScheme(
                settingsColorScheme == .dark ?
                    .dark :
                    settingsColorScheme == .light ? .light :
                    defaultColorScheme
            )
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
    }
}

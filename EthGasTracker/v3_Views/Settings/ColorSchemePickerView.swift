//
//  ColorSchemePickerView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

enum ColorScheme: Int, CaseIterable, Identifiable {
    case none = 0
    case dark = 1
    case light = 2
    
    var id: Int { self.rawValue }
}

struct ColorSchemePickerView: View {
    @AppStorage("userSettings.colorScheme") var settingsColorScheme: ColorScheme = .none
    
    var body: some View {
        HStack {
            Image(systemName: "moon.fill")
                .frame(width: 32, height: 32)
                .background(Color(.systemGray), in: RoundedRectangle(cornerRadius: 8))
                .foregroundColor(Color.white)
            Picker("Color Scheme", selection: $settingsColorScheme) {
                ForEach(ColorScheme.allCases) { colorScheme in
                    Text(colorScheme.description).tag(colorScheme)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

extension ColorScheme: CustomStringConvertible {
    var description: String {
        switch self {
        case .none: return "Default"
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
}

struct ColorSchemePicker_Previews: PreviewProvider {
    static var previews: some View {
        ColorSchemePickerView()
    }
}

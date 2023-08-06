//
//  MenuBar.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

struct MenuBarView: View {
    @State private var showingSettings = false
    
    var body: some View {
        HStack {
            Button(action: {
                showingSettings.toggle()
            }) {
                VStack {
                    Image(systemName: "gear")
                        .padding(2)
//                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    Text("Settings").font(.caption)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView(isPresented: $showingSettings)
                        .presentationDetents([.large])
                }
            }
        }
    }
}
struct MenuBar_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
    }
}

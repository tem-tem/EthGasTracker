//
//  MainMenuView.swift
//  EthGasTracker
//
//  Created by Tem on 1/24/24.
//

import SwiftUI

struct MainMenuView: View {
    @Binding var selectedTab: Int
    var color: Color
    
    var body: some View {
        HStack {
            Button {
                withAnimation(.easeInOut) {
                    selectedTab = 0
                }
            } label: {
                Image(systemName: "bell.fill")
                    .foregroundStyle(selectedTab == 0 ? color : .secondary)
            }
            Spacer()
            Button {
                withAnimation(.easeInOut) {
                    selectedTab = 1
                }
            } label: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(selectedTab == 1 ? color : .secondary)
            }
            Spacer()
            Button {
                withAnimation(.easeInOut) {
                    selectedTab = 2
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(selectedTab == 2 ? color : .secondary)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .foregroundColor(.secondary)
        .font(.title3)
    }
}

#Preview {
    MainMenuView(
        selectedTab: .constant(1),
        color: .red
        )
}

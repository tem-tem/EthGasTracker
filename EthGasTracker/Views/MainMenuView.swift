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
    
    let iconSize: CGFloat = 20.0
    
    var body: some View {
        HStack {
//            Button {
//                withAnimation(.easeInOut) {
//                    selectedTab = 0
//                }
//            } label: {
//                VStack(spacing: 5) {
//                    Image(systemName: "arrow.left.arrow.right.circle.fill")
//                        .frame(width: iconSize, height: iconSize)
//                    Text("Tracker")
//                        .font(.caption)
//                }
//                .foregroundStyle(selectedTab == 0 ? .primary : .secondary)
//                .overlay(alignment: .topTrailing) {
//                    Text("Beta")
//                        .font(.caption)
//                        .foregroundColor(Color("BG.L0"))
//                        .padding(.horizontal, 4)
//                        .padding(.vertical, 2)
//                        .background(selectedTab == 0 ? .primary : .secondary)
//                        .clipShape(RoundedRectangle(cornerRadius: 4))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 4)
//                                .stroke(Color("BG.L0"), lineWidth: 1)
//                        )
//                        .offset(x: 10, y: -15)
//                }
//            }
//            Spacer()
            Button {
                withAnimation(.easeInOut) {
                    selectedTab = 1
                }
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "bitcoinsign")
                        .frame(width: iconSize, height: iconSize)
                    Text("Bitcoin")
                        .font(.caption)
                }
                .foregroundStyle(selectedTab == 1 ? .primary : .secondary)
            }
            Spacer()
            Button {
                withAnimation(.easeInOut) {
                    selectedTab = 2
                }
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .frame(width: iconSize, height: iconSize)
                    Text("ETH")
                        .font(.caption)
                }
                .foregroundStyle(selectedTab == 2 ? .primary : .secondary)
            }
            Spacer()
            Button {
                withAnimation(.easeInOut) {
                    selectedTab = 3
                }
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "gearshape.fill")
                        .frame(width: iconSize, height: iconSize)
                    Text("Settings")
                        .font(.caption)
                }
                .foregroundStyle(selectedTab == 3 ? .primary : .secondary)
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
        selectedTab: .constant(0),
        color: .red
        )
}

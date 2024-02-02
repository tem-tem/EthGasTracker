//
//  DotGridView.swift
//  EthGasTracker
//
//  Created by Tem on 1/17/24.
//

import SwiftUI

struct DotGridView: View {
    @State private var isLoaded: Bool = false
    var height: Int {
        Int(UIScreen.main.bounds.height) / 20
    }
    var width: Int {
        Int(UIScreen.main.bounds.width) / 20
    }
    
    var body: some View {
        HStack(alignment: .center) {
            if (!isLoaded) {
                Spacer()
            }
            ForEach(1...width, id: \.self) { k in
                if (!isLoaded) {
                    Spacer()
                }
                VStack(alignment: .center) {
                    ForEach(1...height, id: \.self) { i in
                        Circle()
                            .size(CGSize(width: 1, height: 1))
                            .fill(.primary)
                        if (i != height) {
                            Spacer()
                        }
                    }
                }
                .frame(width: 1)
                if (k != width && isLoaded) {
                    Spacer()
                }
            }
        }
        .opacity(isLoaded ? 1 : 0)
//        .frame(height: CHART_HEIGHT)
//        .padding(.horizontal)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoaded = true
            }
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 1)) {
                isLoaded = false
            }
        }
    }
}

#Preview {
    DotGridView()
}

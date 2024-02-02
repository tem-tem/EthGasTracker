//
//  InfiniteScrollView.swift
//  EthGasTracker
//
//  Created by Tem on 1/17/24.
//

import SwiftUI

struct InfiniteScroller<Content: View>: View {
    var contentWidth: CGFloat
    var duration: TimeInterval
    var content: (() -> Content)

    @State
    var xOffset: CGFloat = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    content()
                    content()
                }
                .offset(x: xOffset, y: 0)
        }
        .disabled(true)
        .onAppear {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                xOffset = -contentWidth
            }
        }
    }
}

struct InfiniteScrollView<Content: View>: View {
    var itemsAmount: Int
    var content: (() -> Content)
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width / CGFloat(itemsAmount)
//            let _ = print(geometry)
            
            InfiniteScroller(contentWidth: size * CGFloat(itemsAmount), duration: 30) {
                content()
            }
        }
    }
    
}

struct ColorView: View {
    var size: CGFloat
    var color: Color
    
    var body: some View {
        VStack {
            VStack{}.frame(width: size, height: size, alignment: .center)
        }
        .background(color)
    }
}

#Preview {
    InfiniteScrollView(itemsAmount: 6) {
        HStack(spacing: 0) {
            ColorView(size: 100, color: .red)
            ColorView(size: 100, color: .blue)
            ColorView(size: 100, color: .green)
            ColorView(size: 100, color: .yellow)
            ColorView(size: 100, color: .orange)
            ColorView(size: 100, color: .brown)
        }
    }
}

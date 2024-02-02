//
//  HelperViews.swift
//  EthGasTracker
//
//  Created by Tem on 11/19/23.
//

import Foundation
import SwiftUI

struct VStackWithRoundedBorder<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 10
    var overlayOpacity: Double = 0.4
    var padding: CGFloat = 4

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.secondary.opacity(overlayOpacity), lineWidth: 1)
        )
    }
}
struct HStackWithRoundedBorder<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 10
    var overlayOpacity: Double = 0.4
    var padding: CGFloat = 4

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack {
            content
        }
        .padding(.vertical, 2)
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.secondary.opacity(overlayOpacity), lineWidth: 1)
        )
    }
}

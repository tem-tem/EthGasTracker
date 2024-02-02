//
//  TabView.swift
//  EthGasTracker
//
//  Created by Tem on 6/21/23.
//

import SwiftUI

struct MessagesView: View {
    var body: some View {
        TabView {
            VStack {
                Text("Boom bada boom! Widgets are here.")
                    .padding(.bottom)
            }
            Text("Marlen is gay.")
                .padding(.bottom)
//            Image("widgets")
//            Image("widgets")
//            Image("widgets")
        }
//        .font(.title)
//        .background(Color(.systemGroupedBackground))
        .background(Color(UIColor.secondarySystemBackground))
        .tabViewStyle(.page)
        .indexViewStyle(.page)
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}

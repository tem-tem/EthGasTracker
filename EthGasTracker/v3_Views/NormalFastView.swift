//
//  SwiftUIView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

struct NormalFastView: View {
    let name: String
    let normal: Float
    let fast: Float
    let currency: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name).bold()
            HStack {
                Text("Normal")
                Spacer()
                Text("Fast")
            }.font(.caption)
            HStack {
                if (currency != nil) {
                    Text(normal, format: .currency(code: currency ?? "usd"))
                } else {
                    Text(normal, format: .number)
                }
                Spacer()
                if (currency != nil) {
                    Text(fast, format: .currency(code: currency ?? "usd"))
                } else {
                    Text(fast, format: .number)
                }
            }.bold().font(.title)
        }
    }
}

struct NormalFastView_Previews: PreviewProvider {
    static var previews: some View {
        NormalFastView(name: "E", normal: 1.0, fast: 2.0, currency: nil)
    }
}

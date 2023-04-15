//
//  PlainGasView.swift
//  EthGasTracker
//
//  Created by Tem on 4/14/23.
//

import SwiftUI

struct PlainGasView: View {
    @AppStorage("FastGasPrice") var high = "00"
    @AppStorage("ProposeGasPrice") var avg = "00"
    @AppStorage("SafeGasPrice") var low = "00"
    
    var body: some View {
        VStack (alignment: .center) {
            HStack {
                Text("Ethereum Gas Price")
                Spacer()
            }
            Divider()
                .padding(1)
            VStack(spacing: 0) {
                Text(avg).font(.system(size: 100).bold()).padding(.bottom, -10)
                Text("Average")
            }.padding(.bottom, 20)
            
            HStack {
                VStack (alignment: .leading) {
                    Text(low).font(.system(size: 70)).padding(.bottom, -20)
                    Text("Low")
                }
                Spacer()
                VStack (alignment: .trailing) {
                    Text(high).font(.system(size: 70)).padding(.bottom, -20)
                    Text("High")
                }
            }
            Spacer()
        }
    }
}

struct PlainGasView_Previews: PreviewProvider {
    static var previews: some View {
        PlainGasView()
    }
}

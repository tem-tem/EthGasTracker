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
                Text("Ethereum Gas Price").bold()
                Spacer()
            }
            Divider()
                .padding(1)
            VStack(spacing: 0) {
                Text(avg).font(.system(size: 100).bold())
                    .padding(.bottom, -10)
                HStack {
                    Image(systemName: "circle.slash").foregroundColor(.blue)
                    Text("Average").font(.caption)
                }
            }.padding(.bottom, -50)
            
            HStack {
                VStack (alignment: .leading) {
                    Text(low).font(.system(size: 70).weight(.thin))
                        .padding(.bottom, -10)
//                    Text("Low").font(.caption)
//                        .padding(.leading, 5)
                    HStack {
                        Image(systemName: "arrow.down").foregroundColor(.green)
                        Text("Low").font(.caption)
                    }
                }
                Spacer()
                VStack (alignment: .trailing) {
                    Text(high).font(.system(size: 70).weight(.thin))
                        .padding(.bottom, -10)
//                    Text("High").font(.caption)
//                        .padding(.trailing, 5)
                    HStack {
                        Image(systemName: "arrow.up").foregroundColor(.red)
                        Text("High").font(.caption)
                    }
                    .padding(.trailing, 5)
                }
            }
        }
    }
}

struct PlainGasView_Previews: PreviewProvider {
    static var previews: some View {
        PlainGasView()
    }
}

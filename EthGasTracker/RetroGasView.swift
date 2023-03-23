//
//  RetroGasView.swift
//  EthGasTracker
//
//  Created by Tem on 3/16/23.
//

import SwiftUI

struct RetroGasView: View {
    @AppStorage("FastGasPrice") var high = "00"
    @AppStorage("ProposeGasPrice") var avg = "00"
    @AppStorage("SafeGasPrice") var low = "00"
    @AppStorage("gasUsedRatio") var usage = "00%"
    
    @AppStorage("timestamp") var timestamp: Int = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(high).font(Font.custom("Futura", size: 60)).foregroundColor(.red)
            Text("💩 HIGH 👻").font(.caption).foregroundColor(.gray)
            Spacer()
            Text(avg).font(Font.custom("Impact", size: 120).bold())
//                .kerning(-10)
                .foregroundColor(.blue)
            Text("🤣 AVERAGE 🤣🤣").font(.caption).foregroundColor(.gray)
            Spacer()
            Text(low).font(Font.custom("Times New Roman", size: 60)).foregroundColor(.green)
            Text("🫰 Low ").font(.caption).foregroundColor(.gray)
////            RetroText(value: high, color: Color.red, size: 60)
////            Image(systemName: "arrowtriangle.up.fill")
////                .foregroundColor(.red)
////                .opacity(0.5)
//            Text("HIGH").font(.caption).foregroundColor(.gray)
//            HStack {
////                Image(systemName: "arrowtriangle.right.fill")
////                    .foregroundColor(.blue)
////                    .opacity(0.5)
////                RetroText(value: avg, color: Color.blue)
////                Image(systemName: "arrowtriangle.left.fill")
////                    .foregroundColor(.blue)
////                    .opacity(0.5)
//            }
//            Text("AVERAGE").font(.caption).foregroundColor(.gray)
//            Spacer()
////            RetroText(value: low, color: Color.green, size: 60)
////            Image(systemName: "arrowtriangle.down.fill")
////                .foregroundColor(.green)
////                .opacity(0.5)
        }.frame(height: 400)
    }
}

struct RetroGasView_Previews: PreviewProvider {
    static var previews: some View {
        RetroGasView()
    }
}

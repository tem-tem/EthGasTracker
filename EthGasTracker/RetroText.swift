//
//  RetroView.swift
//  EthGasTracker
//
//  Created by Tem on 3/16/23.
//

import SwiftUI

struct RetroText: View {
    var value = "00"
    var color = Color.blue
    var size = 80
    var primary = true
    
    var body: some View {
        ZStack {
            Text(value)
                .foregroundColor(color)
                .font(Font.custom(primary ? "Pilot Command Gradient" : "Pilot Command Condensed", size: CGFloat(size)))
                .blur(radius: CGFloat(size) / 4)
                .opacity(primary ? 1 : 0.5)
            Text(value)
                .foregroundColor(color)
                .font(Font.custom(primary ? "Pilot Command Gradient" : "Pilot Command Condensed", size: CGFloat(size)))
                .blur(radius: 0.1)
        }
    }
}

struct RetroView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RetroText(value: "TEST", color: Color.red, size: 20, primary: false)
            RetroText(value: "34", color: Color.red, size: 80)
        }
    }
}

//
//  LargeNumberView.swift
//  EthGasTracker
//
//  Created by Tem on 8/20/23.
//

import SwiftUI

let DEFAULT_SIZE = 69

struct StyledTextView: View {
    var text: String
    var size: Int? = DEFAULT_SIZE
    
    var body: some View {
        Text(text)
            .font(.system(size: CGFloat(size ?? DEFAULT_SIZE), design: .rounded))
            .bold()
            .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
            .lineLimit(1)
            .foregroundStyle(
                Color("avg").gradient
                    .shadow(.inner(color: Color("avgLight").opacity(1), radius: 4, x: 0, y: 0))
            )
//            .shadow(color: Color("avg").opacity(0.2), radius: 10)
//            .shadow(color: Color("avgLight"), radius: 2)
    }
}

struct LargeNumberView_Previews: PreviewProvider {
    static var previews: some View {
        StyledTextView(text: "24", size: 100)
    }
}

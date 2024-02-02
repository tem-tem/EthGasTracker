//
//  TimerView.swift
//  EthGasTracker
//
//  Created by Tem on 3/15/23.
//

import SwiftUI

struct TimerView: View {
    @State private var remainingTime = 9
    @State private var remainingTimeString = "9"
    
    var body: some View {
        HStack {
            Text("\(remainingTime)")
                .onAppear {
                    let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                        if remainingTime > 0 {
                            remainingTime -= 1
                        } else {
                            timer.invalidate()
                        }
                    }
                }
                .onChange(of: remainingTime, perform: {value in
                    remainingTimeString = "\(value)"
                })
        }
    }
}

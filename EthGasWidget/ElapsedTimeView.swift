//
//  ElapsedTimeView.swift
//  EthGasTracker
//
//  Created by Tem on 5/15/23.
//

import SwiftUI

struct ElapsedTimeView: View {
    @State private var currentDate = Date()
    let entryDate: TimeInterval

    init(timestamp: TimeInterval) {
        self.entryDate = timestamp
    }

    private var elapsedTime: String {
        let date = Date(timeIntervalSince1970: entryDate)
        let interval = currentDate.timeIntervalSince(date)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        
        return formatter.string(from: interval) ?? "Unknown time"
    }

    var body: some View {
        Text("\(elapsedTime) ago")
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    currentDate = Date()
                }
            }
    }
}


struct ElapsedTimeView_Previews: PreviewProvider {
    static var previews: some View {
        ElapsedTimeView(timestamp: Date.now.timeIntervalSince1970)
    }
}

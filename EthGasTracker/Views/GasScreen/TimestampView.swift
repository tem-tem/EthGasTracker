//
//  TimestampView.swift
//  EthGasTracker
//
//  Created by Tem on 1/18/24.
//

import SwiftUI

struct TimestampView: View {
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    var timestamp: Double = 0
    
    var date: Date {
        if let date = activeSelectionVM.date {
            return date
        }
        if let date = activeSelectionVM.historicalData?.date {
            return date
        }
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
//    var dateFromTimestamp: Date {
//        Date(timeIntervalSince1970: TimeInterval(timestamp))
//    }

    var customDateFormat: String {
        let currentDate = Date()

        if date.isSameDay(as: currentDate) {
            return "HH:mm:ss"
        } else if date.isSameMonth(as: currentDate) {
            return "dd HH:mm:ss"
        } else if date.isSameYear(as: currentDate) {
            return "MMM dd HH:mm:ss"
        } else {
            return "yyyy MMM dd HH:mm:ss"
        }
    }
    
    var body: some View {
        Text(date, formatter: DateFormatter.customDateFormatter(withFormat: customDateFormat))
            .font(.system(.caption, design: .monospaced))
    }
}

#Preview {
    TimestampView(timestamp: 324923842)
}


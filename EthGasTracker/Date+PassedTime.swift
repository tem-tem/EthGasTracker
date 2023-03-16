//
//  Date+PassedTime.swift
//  EthGasTracker
//
//  Created by Tem on 3/15/23.
//

import Foundation

extension Date {
    func passedTime(from date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date, to: self)
        
        guard let hours = components.hour,
              let minutes = components.minute,
              let seconds = components.second
        else {
            return ""
        }
        
        let timeString: String
        
        if hours > 0 {
            timeString = String(format: "%d:%d:%d", hours, minutes, seconds)
        } else if minutes > 0 {
            timeString = String(format: "%d:%d", minutes, seconds)
        } else {
            timeString = String(format: "%ds", seconds)
        }
        
        return timeString
    }
}

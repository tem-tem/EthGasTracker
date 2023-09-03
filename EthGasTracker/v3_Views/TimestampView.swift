//
//  TimestampView.swift
//  EthGasTracker
//
//  Created by Tem on 8/6/23.
//

import SwiftUI

struct TimestampView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @Binding var selectedDate: Date?
    @AppStorage("isStale") var isStale = false
//    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
//    let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//        return formatter
//    }()
//    if let date = selectedDate {
//        Text("\(date, formatter: dateFormatter)")
//    }
        
    var dateFromTimestamp: Date {
        Date(timeIntervalSince1970: TimeInterval(appDelegate.timestamp))
    }

    var customDateFormat: String {
        let currentDate = Date()

        if dateFromTimestamp.isSameDay(as: currentDate) {
            return "HH:mm:ss"
        } else if dateFromTimestamp.isSameMonth(as: currentDate) {
            return "dd HH:mm:ss"
        } else if dateFromTimestamp.isSameYear(as: currentDate) {
            return "MMM dd HH:mm:ss"
        } else {
            return "yyyy MMM dd HH:mm:ss"
        }
    }

    var body: some View {
        HStack(alignment: .center) {
            if let date = selectedDate {
                Image(systemName: "arrow.left")
                Text(date, formatter: DateFormatter.customDateFormatter(withFormat: customDateFormat))
                let timeDiff = date.timeIntervalSince(dateFromTimestamp)
                let hours = Int(timeDiff) / 3600
                let minutes = (Int(timeDiff) % 3600) / 60
                let seconds = Int(timeDiff) % 60

                Text(String(format: "-%02dm%02ds", abs(minutes), abs(seconds)))
                    .opacity(0.5)
//                Text("@") +
            } else {
                if (isStale) {
                    if (appDelegate.timestamp > 0) {
                        Image(systemName: "clock.badge.exclamationmark")
                            .foregroundColor(Color(.systemOrange))
                    } else {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color(.systemOrange))
                    }
                } else {
                    Image(systemName: "clock.badge.checkmark")
//                        .foregroundColor(Color(.systemGreen))
                }
                VStack(alignment: .leading) {
                    if isStale {
                        if (appDelegate.timestamp > 0) {
    //                        Text("Data is stale")
                            Text(dateFromTimestamp, formatter: DateFormatter.customDateFormatter(withFormat: customDateFormat))
                        }
                        else {
                            Text("Data not received")
                        }
                    } else {
    //                    Text("Fresh")
                        Text(dateFromTimestamp, formatter: DateFormatter.customDateFormatter(withFormat: customDateFormat))
                    }
                }
            }
        }
        .font(.system(.caption, design: .monospaced))
//        .onReceive(timer) { _ in
//            isStale = Date().timeIntervalSince(dateFromTimestamp) > 60
//            // This will cause the view to re-evaluate the `isStale` property every second
//        }
    }
}

extension DateFormatter {
    static func customDateFormatter(withFormat format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
}


//struct TimestampView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewWrapper {
//            TimestampView()
//        }
//    }
//}

extension Date {
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func isSameMonth(as date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
    
    func isSameYear(as date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
    }
}

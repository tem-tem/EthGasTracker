////
////  TimestampView.swift
////  EthGasTracker
////
////  Created by Tem on 8/6/23.
////
//
//import SwiftUI
//
//struct TimeAgoView: View {
//    @EnvironmentObject var appDelegate: AppDelegate
//    @Binding var selectedDate: Date?
//    @Binding var selectedHistoricalData: HistoricalData?
//    
//    var activeDate: Date? {
//        if let date = selectedDate {
//            return date
//        }
//        if let date = selectedHistoricalData?.date {
//            return date
//        }
//        return nil
//    }
//    var dateFromTimestamp: Date {
//        Date(timeIntervalSince1970: TimeInterval(appDelegate.timestamp))
//    }
//
//    var customDateFormat: String {
//        let currentDate = Date()
//
//        if let date = activeDate {
//            if date.isSameDay(as: currentDate) {
//                return "HH:mm:ss"
//            } else if date.isSameMonth(as: currentDate) {
//                return "MMM dd HH:mm:ss"
//            } else if date.isSameYear(as: currentDate) {
//                return "MMM dd HH:mm:ss"
//            } else {
//                return "yyyy MMM dd HH:mm:ss"
//            }
//        } else {
//            return "HH:mm:ss"
//        }
//    }
//    
//    var body: some View {
//        HStack {
//            if let date = activeDate {
////                Image(systemName: "arrow.left")
//                Text(date, formatter: DateFormatter.customDateFormatter(withFormat: customDateFormat))
////                let timeDiff = date.timeIntervalSince(dateFromTimestamp)
////                let hours = Int(timeDiff) / 3600
////                let minutes = (Int(timeDiff) % 3600) / 60
////                let seconds = Int(timeDiff) % 60
//
////                Text(String(format: "-%02dm%02ds", abs(minutes), abs(seconds)))
////                    .opacity(0.5)
//            }
//        }
//        .font(.system(.title3, design: .monospaced))
//    }
//}
//
//struct TimestampViewLegacy: View {
//    @EnvironmentObject var appDelegate: AppDelegate
//    @Binding var selectedDate: Date?
//    @AppStorage("isStale") var isStale = false
////    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    
////    let dateFormatter: DateFormatter = {
////        let formatter = DateFormatter()
////        formatter.dateFormat = "HH:mm:ss"
////        return formatter
////    }()
////    if let date = selectedDate {
////        Text("\(date, formatter: dateFormatter)")
////    }
//        
//    var dateFromTimestamp: Date {
//        Date(timeIntervalSince1970: TimeInterval(appDelegate.timestamp))
//    }
//
//    var customDateFormat: String {
//        let currentDate = Date()
//
//        if dateFromTimestamp.isSameDay(as: currentDate) {
//            return "HH:mm:ss"
//        } else if dateFromTimestamp.isSameMonth(as: currentDate) {
//            return "dd HH:mm:ss"
//        } else if dateFromTimestamp.isSameYear(as: currentDate) {
//            return "MMM dd HH:mm:ss"
//        } else {
//            return "yyyy MMM dd HH:mm:ss"
//        }
//    }
//
//    var body: some View {
//        HStack(alignment: .center) {
//            if (isStale) {
//                if (appDelegate.timestamp > 0) {
//                    Image(systemName: "clock.badge.exclamationmark")
//                        .foregroundColor(Color(.systemOrange))
//                } else {
//                    Image(systemName: "exclamationmark.triangle.fill")
//                        .foregroundColor(Color(.systemOrange))
//                }
//            } else {
//                Image(systemName: "clock.badge.checkmark")
////                        .foregroundColor(Color(.systemGreen))
//            }
//            VStack(alignment: .leading) {
//                if isStale {
//                    if (appDelegate.timestamp > 0) {
////                        Text("Data is stale")
//                        Text(dateFromTimestamp, formatter: DateFormatter.customDateFormatter(withFormat: customDateFormat))
//                    }
//                    else {
//                        Text("Data not received")
//                    }
//                } else {
////                    Text("Fresh")
//                    Text(dateFromTimestamp, formatter: DateFormatter.customDateFormatter(withFormat: customDateFormat))
//                }
//            }
//        }
//        .font(.system(.caption, design: .monospaced))
////        .onReceive(timer) { _ in
////            isStale = Date().timeIntervalSince(dateFromTimestamp) > 60
////            // This will cause the view to re-evaluate the `isStale` property every second
////        }
//    }
//}
//
//
//
////struct TimestampView_Previews: PreviewProvider {
////    static var previews: some View {
////        PreviewWrapper {
////            TimestampView()
////        }
////    }
////}
//

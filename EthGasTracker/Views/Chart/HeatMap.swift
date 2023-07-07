//
//  HeatMap.swift
//  EthGasTracker
//
//  Created by Tem on 5/12/23.
//

import SwiftUI
import Charts
import Foundation

struct HeatMap: View {
    private var statsLoader = StatsLoader()
    private var stats: [Stat]
    private var startHour: Int?
    @AppStorage("minInAllStats") var minInAllStats: Double = 0
    @AppStorage("maxInAllStats") var maxInAllStats: Double = 1000
    private var width: Double = 60
    private var avgList: [String: Double] = [:]
    private var minAvg: Double = 0
    private var maxAvg: Double = 100.0
    
    init() {
        stats = statsLoader.loadStatsFromUserDefaults()
        startHour = lastIndexWithZeroHours(stats: stats)
        stats = stats.prefix(startHour ?? stats.count).reversed()
        
        let numberOfDigits = floor(log10(maxInAllStats) + 1)
        width = numberOfDigits * 20
        
        let avgListByHour = averageGasPricesByHour(stats: stats)
        if let (minGasPrice, maxGasPrice) = minAndMaxGasPrices(averageGasPrices: avgListByHour) {
            minAvg = minGasPrice.1
            maxAvg = maxGasPrice.1
        } else {
            minAvg = 0
            maxAvg = 100
        }
        
        avgList = avgListByHour
    }
    
    let stackColors: [Color] = [
        Color("0").opacity(0.2),
        Color("1").opacity(0.1),
        Color("2").opacity(0.1),
        Color("3").opacity(0.1),
        Color("4").opacity(0.1),
        Color("5").opacity(0.2)
    ]
    
    let rows = Array(repeating: GridItem(), count: 25)
    
    var body: some View {
        
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 5, pinnedViews: [.sectionHeaders]) {
                        Section(header: HStack {
                            LazyHGrid(rows: rows, spacing: 0) {
                                Text("30 day AVG")
                                    .padding(.horizontal, 10)
                                    .padding(.top, 20)
                                    .padding(.bottom, 10)
                                    .font(.caption)
                                ForEach(0..<24) { hour in
                                    HStack {
                                        Text("\(Int(avgList[String(format: "%02d:00", hour)] ?? 0))")
                                            .padding(.horizontal, 5)
                                            .background(
                                                colorForValue(value: avgList[String(format: "%02d:00", hour)] ?? 0.0, min: minAvg, max: maxAvg).opacity(0.1)
                                            )
                                            .cornerRadius(3)
                                        Spacer()
                                        Text(String(format: "%02d:00", hour))
                                    }
                                    .font(.caption)
                                    .foregroundColor(
                                        colorForValue(value: avgList[String(format: "%02d:00", hour)] ?? 0.0, min: minAvg, max: maxAvg)
                                    )
                                    .padding(.horizontal, 10)
                                }
                            }
                            .frame(width: 80)
                            Divider()
                        }
                            .background(Color(.systemBackground))
//                            .padding(.top, 2)
                        ) {
                            ForEach(Array(stats.indices), id: \.self) { index in
                                let currentHourStat = stats[index]
                                if let currentDate = dateStringToDate(currentHourStat.timestamp_utc) {
                                    if Calendar.current.component(.hour, from: currentDate) == 0 {
                                        Text(shortDateFormatter.string(from: currentDate))
                                            .font(.caption)
                                            .padding(.top, 20)
                                            .padding(.bottom, 10)
                                    }

                                    Text("\(Int(currentHourStat.average_gas_price))")
                                        .frame(width: width)
                                        .padding(.horizontal, 10)
                                        .foregroundColor(
                                            colorForValue(value: currentHourStat.average_gas_price, min: minInAllStats, max: maxInAllStats))
                                        .background(
                                            colorForValue(value: currentHourStat.average_gas_price, min: minInAllStats, max: maxInAllStats).opacity(0.2)
                                        )
                                        .cornerRadius(5)

                                    // Checking if there is a nextHourStat and if its timestamp is more than the current one by 2 or more hours.
                                    if index < stats.count - 1 {
                                        let nextHourStat = stats[index + 1]
                                        if let nextDate = dateStringToDate(nextHourStat.timestamp_utc),
                                           let currentDate = dateStringToDate(currentHourStat.timestamp_utc),
                                           let hourDifference = Calendar.current.dateComponents([.hour], from: currentDate, to: nextDate).hour,
                                           hourDifference >= 2 {
                                            
                                            // Add placeholder Text for each hour of difference.
                                            ForEach(0..<hourDifference-1, id: \.self) { _ in
                                                Image(systemName: "bolt.slash.fill")
                                                    .frame(width: width)
                                                    .padding(.horizontal, 10)
                                                    .foregroundColor(
                                                        Color.secondary.opacity(0.8)
                                                    )
                                                    .background(
                                                        Color.secondary.opacity(0.2)
                                                    )
                                                    .cornerRadius(5)
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }


                    }
                    .id("HeatmapChart")
                    .padding(.trailing, 80)
            }
            .onAppear {
                scrollToTheEnd(using: scrollProxy, id: "HeatmapChart")
            }
        }
        
    }
    
    private func scrollToTheEnd(using scrollProxy: ScrollViewProxy, id: String) {
        withAnimation {
            scrollProxy.scrollTo(id, anchor: .trailing)
        }
    }
    
    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
        let today = Date()
        let dayString = dateFormatter.string(from: today)
        
        return dayString
    }
    
    private let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter
    }()
}

func lastIndexWithZeroHours(stats: [Stat]) -> Int? {
    for (index, stat) in stats.enumerated().reversed() {
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: stat.timestamp_utc) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            if hour == 0 {
                return index + 1
            }
        }
    }
    return nil
}

func fillInMissedHours(stats: [Stat]) -> [Stat] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'" // Adjust this to match your date string format

    var filledStats = stats // Copy the original stats
    var placeholders = [Stat]() // Temp array to hold the placeholders
    print("first \(stats[0].timestamp_utc)")

    for i in 0..<stats.count - 1 {
        let date1 = dateFormatter.date(from: stats[i].timestamp_utc)
        let date2 = dateFormatter.date(from: stats[i+1].timestamp_utc)
        if let date1 = date1, let date2 = date2 {
            let hour1 = Calendar.current.component(.hour, from: date1)
            let hour2 = Calendar.current.component(.hour, from: date2)
            let day1 = Calendar.current.component(.day, from: date1)
            let day2 = Calendar.current.component(.day, from: date2)
            var diffInHours = hour2 - hour1

            // Consider the case when date2 is on the next day
            if day2 != day1 {
                diffInHours += 24
            }

            // If the difference in hours is more than 1.5, add placeholders
            if diffInHours > 1 {
                for j in 1..<diffInHours {
                    let placeholderDate = Calendar.current.date(byAdding: .hour, value: j, to: date1)!
                    let placeholderTimestamp = dateFormatter.string(from: placeholderDate)
                    placeholders.append(Stat(average_gas_price: 0.0, timestamp_utc: placeholderTimestamp))
                }
            }
        }
    }

    // Concatenate the placeholders and sort the array
    filledStats.append(contentsOf: placeholders)
    filledStats.sort { $0.timestamp_utc < $1.timestamp_utc }
    
    // Find the first index that is at the start of a day
    if let firstZeroHourIndex = filledStats.firstIndex(where: { stat in
        if let date = dateFormatter.date(from: stat.timestamp_utc) {
            let hour = Calendar.current.component(.hour, from: date)
            return hour == 0
        }
        return false
    }) {
        
        print("first after \(filledStats[0].timestamp_utc)")
        return Array(filledStats[firstZeroHourIndex...])
    }
    print("first after \(filledStats[0].timestamp_utc)")
    return filledStats
}



struct HeatMap_Previews: PreviewProvider {
    static var previews: some View {
        HeatMap()
    }
}

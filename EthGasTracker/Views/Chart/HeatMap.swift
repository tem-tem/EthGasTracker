//
//  HeatMap.swift
//  EthGasTracker
//
//  Created by Tem on 5/12/23.
//

import SwiftUI
import Charts

struct HeatMap: View {
    private var statsLoader = StatsLoader()
    private var stats: [Stat]
    @AppStorage("minInAllStats") var minInAllStats: Double = 0
    @AppStorage("maxInAllStats") var maxInAllStats: Double = 1000
    
    init() {
        stats = statsLoader.loadStatsFromUserDefaults()
    }
    
    private let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        return formatter
    }()
    
    private let barWidth = 40
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        return formatter
    }()
    let stackColors: [Color] = [
        Color("0").opacity(0.2),
        Color("1").opacity(0.1),
        Color("2").opacity(0.1),
        Color("3").opacity(0.1),
        Color("4").opacity(0.1),
        Color("5").opacity(0.2)
    ]
    
    @State private var start: Int?
    @State private var width: Int = 30
//    private let width = 50
//    private let height = 30
    
    var body: some View {
        Chart(stats.prefix(start ?? stats.count).reversed(), id: \.timestamp_utc) { item in
            RectangleMark(
                x: .value("Day", dateFormatter.string(from: dateStringToDate(item.timestamp_utc))),
                y: .value("Hour", hourFormatter.string(from: dateStringToDate(item.timestamp_utc))),
                width: .inset(2),
                height: .inset(2)
            )
            .interpolationMethod(.catmullRom)
            .cornerRadius(5)
            
            .annotation(position: .overlay) { _ in
                Text("\(Int(item.average_gas_price)) ")
                    .foregroundColor(colorForValue(value: item.average_gas_price, min: minInAllStats, max: maxInAllStats).opacity(0.8))
            }
            .foregroundStyle(by: .value("Number", item.average_gas_price))
        }
        .frame(width: CGFloat((stats.count / 24) * width))
        .chartForegroundStyleScale(range: stackColors)
        .chartXAxis {
            AxisMarks() { value in
//                AxisValueLabel(getToday())
                if (getToday() == value.as(String.self)!.prefix(2)) {
                    AxisValueLabel("Today")
                } else {
                    AxisValueLabel(value.as(String.self)!.dropLast(5))
                }
            }
        }
        .chartYAxis(.hidden)
        .onAppear {
            start = lastIndexWithZeroHours(stats: stats)
            maxInAllStats = stats.max { $0.average_gas_price < $1.average_gas_price }?.average_gas_price ?? 1000
            minInAllStats = stats.min { $0.average_gas_price < $1.average_gas_price }?.average_gas_price ?? 0
            if (maxInAllStats > 100) {
                width = (String(abs(Int(maxInAllStats))).count) * 20
            }
        }
    }
    
    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
        let today = Date()
        let dayString = dateFormatter.string(from: today)
        
        return dayString
    }
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

struct HeatMap_Previews: PreviewProvider {
    static var previews: some View {
        HeatMap()
    }
}

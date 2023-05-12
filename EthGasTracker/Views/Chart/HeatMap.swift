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
    @AppStorage("minInStats") var minInStats: Double = 0
    @AppStorage("maxInStats") var maxInStats: Double = 100
    
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
        Color(hex: "F94144").opacity(0.2),
        Color(hex: "F3722C").opacity(0.1),
        Color(hex: "F8961E").opacity(0.1),
        Color(hex: "F9C74F").opacity(0.1),
        Color(hex: "90BE6D").opacity(0.1),
        Color(hex: "3DAC58").opacity(0.2)
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
                    .foregroundColor(colorForValue(value: item.average_gas_price, min: minInStats, max: maxInStats).opacity(0.8))
            }
            .foregroundStyle(by: .value("Number", item.average_gas_price))
        }
        .frame(width: CGFloat((stats.count / 24) * width))
        .chartForegroundStyleScale(range: stackColors.reversed())
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
            if (maxInStats > 100) {
                width = (String(abs(Int(maxInStats))).count) * 20
                
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
    
    func colorForValue(value: Double, min minValue: Double, max maxValue: Double) -> Color {
        guard minValue <= value, value <= maxValue else {
            print("Value must be between min and max.")
            return Color("avg")
        }
        
        let colors = [
            Color(hex: "F94144"),
            Color(hex: "F3722C"),
            Color(hex: "F8961E"),
            Color(hex: "F9C74F"),
            Color(hex: "90BE6D"),
            Color(hex: "43AA8B")
        ]
        
        let range = maxValue - minValue
        let step = Int(Int(range) / (colors.count - 1))
        let index = Int(Int((value - minValue)) / step)
        
        return colors.reversed()[index]
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

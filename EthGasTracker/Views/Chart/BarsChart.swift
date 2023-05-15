//
//  BarsChart.swift
//  EthGasTracker
//
//  Created by Tem on 5/7/23.
//

import SwiftUI
import Charts

struct BarsChart: View {
    private var statsLoader = StatsLoader()
    private var stats: [Stat]
    @AppStorage("minIn48Stats") var minIn48Stats: Double = 0
    @AppStorage("maxIn48Stats") var maxIn48Stats: Double = 1
    @AppStorage("minInAllStats") var minInAllStats: Double = 0
    @AppStorage("maxInAllStats") var maxInAllStats: Double = 1000
    
    init() {
        stats = statsLoader.loadStatsFromUserDefaults()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        return formatter
    }()
    
    private let barWidth = 40
    
    var body: some View {
        Chart(stats.prefix(48), id: \.timestamp_utc) { item in
            
            BarMark(
                x: .value("Hour", dateStringToDate(item.timestamp_utc)),
                y: .value("Price", item.average_gas_price),
                width: MarkDimension(integerLiteral: barWidth)
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [colorForValue(value: item.average_gas_price, min: minIn48Stats, max: maxIn48Stats).opacity(0), colorForValue(value: item.average_gas_price, min: minIn48Stats, max: maxIn48Stats).opacity(0.5)],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .cornerRadius(0)
            .annotation(position: .top, alignment: .center) {
                Text("\(Int(item.average_gas_price))")
                    .foregroundColor(colorForValue(value: item.average_gas_price, min: minIn48Stats, max: maxIn48Stats))
                    .font(.caption)
            }
            .annotation(position: .overlay, alignment: .center) {
                VStack(alignment: .center, spacing: 0) {
                    Rectangle().fill(colorForValue(value: item.average_gas_price, min: minIn48Stats, max: maxIn48Stats)).frame(height: 2).padding(.top, -6)
                    if (maxIn48Stats == item.average_gas_price) {
                        Text("MAX")
                            .foregroundColor(colorForValue(value: item.average_gas_price, min: minIn48Stats, max: maxIn48Stats))
                            .font(.caption2)
                    }
                    if (minIn48Stats == item.average_gas_price) {
                        Text("MIN")
                            .foregroundColor(colorForValue(value: item.average_gas_price, min: minIn48Stats, max: maxIn48Stats))
                            .font(.caption2)
                    }
                    Spacer()
                    Text(dateFormatter.string(from: dateStringToDate(item.timestamp_utc)))
                        .foregroundColor(colorForValue(value: item.average_gas_price, min: minIn48Stats, max: maxIn48Stats))
                        .font(.caption)
                    
                }.frame(width: CGFloat(barWidth))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour)) { value in
                if dateFormatter.string(from: value.as(Date.self)!) == "00:00" {
                    AxisGridLine()
                    AxisValueLabel()
                } else {
                    AxisGridLine()
                }
            }
        }
        .chartYAxis(.hidden)
        .frame(width: CGFloat(48) * CGFloat(barWidth + 5))
        .onAppear {
            maxIn48Stats = stats.prefix(48).max { $0.average_gas_price < $1.average_gas_price }?.average_gas_price ?? 99999
            minIn48Stats = stats.prefix(48).min { $0.average_gas_price < $1.average_gas_price }?.average_gas_price ?? 0
        }
    }
}

func dateStringToDate(_ dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    return dateFormatter.date(from: dateString) ?? Date()
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.hasPrefix("#") ? hex.index(after: hex.startIndex) : hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

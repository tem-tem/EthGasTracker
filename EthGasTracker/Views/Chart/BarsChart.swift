//
//  BarsChart.swift
//  EthGasTracker
//
//  Created by Tem on 5/7/23.
//

import SwiftUI
import Charts
let calendar = Calendar.current

struct BarsChart: View {
    private var statsLoader = StatsLoader()
    private var stats: [Stat]
    @AppStorage("minInStats") var minInStats: Double?
    @AppStorage("maxInStats") var maxInStats: Double?
    
    private let avgColors = [Color("avg").opacity(0), Color("avg").opacity(0.5)]
    
    init() {
        stats = statsLoader.loadStatsFromUserDefaults()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        Chart(stats, id: \.timestamp_utc) { item in
            
            BarMark(
                x: .value("Hour", dateStringToDate(item.timestamp_utc)),
                y: .value("Price", item.average_gas_price),
                width: 40
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [colorForValue(value: item.average_gas_price, min: minInStats ?? 0.0, max: maxInStats ?? 0.0).opacity(0), colorForValue(value: item.average_gas_price, min: minInStats ?? 0.0, max: maxInStats ?? 0.0).opacity(0.5)],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
//            .cornerRadius(10)
            .annotation(position: .top, alignment: .center) {
                Text("\(Int(item.average_gas_price))")
                    .foregroundColor(colorForValue(value: item.average_gas_price, min: minInStats ?? 0.0, max: maxInStats ?? 0.0))
                    .font(.caption)
            }
            .annotation(position: .overlay, alignment: .center) {
                VStack(alignment: .center, spacing: 0) {
                    Rectangle().fill(colorForValue(value: item.average_gas_price, min: minInStats ?? 0.0, max: maxInStats ?? 0.0)).frame(height: 2).padding(.top, -6)
                    if ((maxInStats ?? 0.0) == (item.average_gas_price)) {
                        Text("MAX")
                            .foregroundColor(colorForValue(value: item.average_gas_price, min: minInStats ?? 0.0, max: maxInStats ?? 0.0))
                            .font(.caption)
                    }
                    if ((minInStats ?? 0.0) == (item.average_gas_price)) {
                        Text("MIN")
                            .foregroundColor(colorForValue(value: item.average_gas_price, min: minInStats ?? 0.0, max: maxInStats ?? 0.0))
                            .font(.caption)
                    }
                    Spacer()
                    Text(dateFormatter.string(from: dateStringToDate(item.timestamp_utc)))
                        .foregroundColor(colorForValue(value: item.average_gas_price, min: minInStats ?? 0.0, max: maxInStats ?? 0.0))
                        .font(.caption)
                    
                }.frame(width: 40)
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
        .frame(width: CGFloat(stats.count) * 50)
        .onAppear {
            
            maxInStats = stats.max { $0.average_gas_price < $1.average_gas_price }?.average_gas_price
            minInStats = stats.min { $0.average_gas_price < $1.average_gas_price }?.average_gas_price
        }
    }
    
    func dateStringToDate(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    func colorForValue(value: Double, min minValue: Double, max maxValue: Double) -> Color {
        guard minValue <= value, value <= maxValue else {
            fatalError("Value must be between min and max.")
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
        let colorIndex = min(Int(value), (colors.count - 1))
        
        return colors.reversed()[index]
    }
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

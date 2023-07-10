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
        stats = Array(stats.suffix(48))
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        return formatter
    }()
    
    private let barWidth = 40
    
    var body: some View {
        Chart(stats, id: \.timestamp_utc) { item in
            let currentValueColor = item.average_gas_price > 0 ?
            colorForValue(value: item.average_gas_price, min: minIn48Stats, max: maxIn48Stats) : Color.secondary
            BarMark(
                x: .value("Hour", dateStringToDate(item.timestamp_utc)),
                y: .value("Price", item.average_gas_price),
                width: MarkDimension(integerLiteral: barWidth)
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [currentValueColor.opacity(0), currentValueColor.opacity(0.5)],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .cornerRadius(0)
            .annotation(position: .top, alignment: .center) {
                if (item.average_gas_price > 0) {
                    Text("\(Int(round(item.average_gas_price)))")
                        .foregroundColor(currentValueColor)
                        .font(.caption)
                }
            }
            .annotation(position: .bottom, alignment: .center) {
                Text(dateFormatter.string(from: dateStringToDate(item.timestamp_utc)))
                    .foregroundColor(currentValueColor)
                    .font(.caption)
                
            }
            .annotation(position: .overlay, alignment: .center) {
                VStack(alignment: .center, spacing: 0) {
                    if (item.average_gas_price > 0) {
                        Rectangle().fill(currentValueColor).frame(height: 2).padding(.top, -6)
                    } else {
                        Image(systemName: "bolt.slash.fill")
//                            .frame(width: width)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .padding(.bottom, 10)
                            .foregroundColor(
                                Color.secondary.opacity(0.5)
                            )
                            .background(
                                Color.secondary.opacity(0.1)
                            )
                            .cornerRadius(5)
                    }
                    if (maxIn48Stats == item.average_gas_price) {
                        Text("MAX")
                            .foregroundColor(currentValueColor)
                            .font(.caption2)
                    }
                    if (minIn48Stats == item.average_gas_price) {
                        Text("MIN")
                            .foregroundColor(currentValueColor)
                            .font(.caption2)
                    }
                    Spacer()
                    
                }.frame(width: CGFloat(barWidth))
            }
            
            RuleMark(y: .value("Max", maxIn48Stats))
                .opacity(0.2)
                .foregroundStyle(Color.secondary.opacity(0.2))
                .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [3]))
                .annotation(position: .top, alignment: .trailing) {
                    Text("Max: \(Int(round(maxIn48Stats)))")
                      .font(.caption)
                      .foregroundStyle(Color("5"))
                }
                .offset(y: -2)
            
            RuleMark(y: .value("Min", minIn48Stats))
                .foregroundStyle(Color.secondary.opacity(0.1))
                .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [3]))
              .annotation(position: .bottom, alignment: .trailing) {
                Text("Min: \(Int(round(minIn48Stats)))")
                  .font(.caption)
                  .foregroundStyle(Color("0"))
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
            minIn48Stats = stats.prefix(48).min { 0 < $0.average_gas_price && $0.average_gas_price < $1.average_gas_price }?.average_gas_price ?? 0
        }
    }
}

func dateStringToDate(_ dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    return dateFormatter.date(from: dateString) ?? Date()
}

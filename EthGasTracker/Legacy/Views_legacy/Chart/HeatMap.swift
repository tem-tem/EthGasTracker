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
        
        let numberOfDigits = floor(log10(maxInAllStats) + 1)
        width = numberOfDigits * 15
        
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
                                let currentDate = dateStringToDate(currentHourStat.timestamp_utc)
                                if Calendar.current.component(.hour, from: currentDate) == 0 {
                                    Text(shortDateFormatter.string(from: currentDate))
                                        .font(.caption)
                                        .padding(.top, 20)
                                        .padding(.bottom, 10)
                                }

                                if (currentHourStat.average_gas_price > 0) {
                                    Text("\(Int(round(currentHourStat.average_gas_price)))")
                                        .frame(width: width)
                                        .padding(.horizontal, 10)
                                        .foregroundColor(
                                            colorForValue(value: currentHourStat.average_gas_price, min: minInAllStats, max: maxInAllStats))
                                        .background(
                                            colorForValue(value: currentHourStat.average_gas_price, min: minInAllStats, max: maxInAllStats).opacity(0.2)
                                        )
                                        .cornerRadius(5)
//                                            .font(.caption)
                                } else {
                                    Image(systemName: "bolt.slash.fill")
                                        .frame(width: width)
                                        .padding(.horizontal, 10)
                                        .foregroundColor(
                                            Color.secondary.opacity(0.2)
                                        )
                                        .background(
                                            Color.secondary.opacity(0.1)
                                        )
                                        .cornerRadius(5)
//                                            .font(.caption)
                                    
                                }
                            }
                            
                        }
                    }
                    .padding(.trailing, 20)
                    .id("HeatmapChart")
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



struct HeatMap_Previews: PreviewProvider {
    static var previews: some View {
        HeatMap()
    }
}

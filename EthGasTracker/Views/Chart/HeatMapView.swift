//
//  HeatMapView.swift
//  EthGasTracker
//
//  Created by Tem on 5/12/23.
//

import SwiftUI

func averageGasPricesByHour(stats: [Stat]) -> [String: Double] {
    var groupedStats: [String: [Stat]] = [:]

    // Group the stats by hour
    for stat in stats {
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: stat.timestamp_utc) {
            let hourFormatter = DateFormatter()
            hourFormatter.dateFormat = "HH:00"
            let hourString = hourFormatter.string(from: date)
            if groupedStats[hourString] == nil {
                groupedStats[hourString] = [stat]
            } else {
                groupedStats[hourString]?.append(stat)
            }
        }
    }

    // Calculate the average gas price for each group
    var averageGasPrices: [String: Double] = [:]
    for (hour, stats) in groupedStats {
        let totalGasPrice = stats.reduce(0.0) { $0 + $1.average_gas_price }
        let averageGasPrice = totalGasPrice / Double(stats.count)
        averageGasPrices[hour] = averageGasPrice
    }

    return averageGasPrices
}

func minAndMaxGasPrices(averageGasPrices: [String: Double]) -> (min: (String, Double), max: (String, Double))? {
    guard let firstPrice = averageGasPrices.first else {
        return nil
    }

    var minPrice = firstPrice
    var maxPrice = firstPrice

    for (hour, averageGasPrice) in averageGasPrices {
        if averageGasPrice < minPrice.1 {
            minPrice = (hour, averageGasPrice)
        }
        if averageGasPrice > maxPrice.1 {
            maxPrice = (hour, averageGasPrice)
        }
    }

    return (min: minPrice, max: maxPrice)
}


struct HeatMapView: View {
    @Binding var isPresented: Bool
    private var statsLoader = StatsLoader()
    private var stats: [Stat]
    @State private var avgList: [String: Double]
    @State private var minAvg: Double
    @State private var maxAvg: Double
    
    init(isPresented canShow: Binding<Bool>) {
        stats = statsLoader.loadStatsFromUserDefaults()
        let avgListByHour = averageGasPricesByHour(stats: stats)
        
        if let (minGasPrice, maxGasPrice) = minAndMaxGasPrices(averageGasPrices: avgListByHour) {
            minAvg = minGasPrice.1
            maxAvg = maxGasPrice.1
//            print("\(minAvg) min, \(maxAvg) max ")
        } else {
            minAvg = 0
            maxAvg = 100
            print("No data available.")
        }
        
        avgList = avgListByHour
        
        self._isPresented = canShow
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Last \(stats.count / 24) days").font(.title2).bold()
            Divider()
            HStack (alignment: .top) {
                VStack {
                    ForEach(0..<24) { hour in
                        Text(String(format: "%02d:00", hour))
//                        Text("\(avgList[String(format: "%02d:00", hour)] ?? 0)")
                            .font(.caption)
                            .foregroundColor(
                                colorForValue(value: avgList[String(format: "%02d:00", hour)] ?? 0.0, min: minAvg, max: maxAvg)
                            )
                            .frame(height: 12.24)
                            .padding(.bottom, 2)
                            .padding(.top, 2)
                    }
                }.padding(.top, 5)
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal) {
                        HeatMap()
                            .frame(height: 600)
                            .padding(.bottom, 20)
                            .id("HeatmapChart")
                    }
                    .onAppear {
                        scrollToTheEnd(using: scrollProxy, id: "HeatmapChart")
                    }
                }
                
            }
            HStack {
                Spacer()
                Button("Dismiss") {
                    isPresented = false
                }
                Spacer()
            }
        }
    }
    
    private func scrollToTheEnd(using scrollProxy: ScrollViewProxy, id: String) {
        withAnimation {
            scrollProxy.scrollTo(id, anchor: .trailing)
        }
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

struct HeatMapView_Previews: PreviewProvider {
    static var previews: some View {
        HeatMapView(isPresented: .constant(true))
    }
}

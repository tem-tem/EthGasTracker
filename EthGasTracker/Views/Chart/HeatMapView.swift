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
    
    init(isPresented canShow: Binding<Bool>) {
        stats = statsLoader.loadStatsFromUserDefaults()
//        let avgListByHour = averageGasPricesByHour(stats: stats)
//
//        if let (minGasPrice, maxGasPrice) = minAndMaxGasPrices(averageGasPrices: avgListByHour) {
//            minAvg = minGasPrice.1
//            maxAvg = maxGasPrice.1
//        } else {
//            minAvg = 0
//            maxAvg = 100
//            print("No data available.")
//        }
//
//        avgList = avgListByHour

        self._isPresented = canShow
    }
//
    let rows = Array(repeating: GridItem(), count: 24)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
//            Text("Last \(stats.count / 24) days").font(.title2).bold()
//                .padding(10)
////            Divider().padding(0)
//            Divider()
            HeatMap()
//                .padding(0)
                .frame(maxHeight: .infinity)
//                .frame(height: 600)
            Divider()
            HStack {
                Spacer()
                Button("Dismiss") {
                    isPresented = false
                }
                Spacer()
            }.padding(10)
        }
    }
}

struct HeatMapView_Previews: PreviewProvider {
    static var previews: some View {
        HeatMapView(isPresented: .constant(true))
    }
}

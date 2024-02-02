//
//  StatsVM.swift
//  EthGasTracker
//
//  Created by Tem on 1/29/24.
//

import Foundation

class StatsVM: ObservableObject {
    let apiManager: APIManager
    @Published var stats: StatsEntries = StatsEntries(statsNormal: [], statsGroupedByHourNormal: [], statsFast: [], statsGroupedByHourFast: [], timestamp: Date(timeIntervalSince1970: 0), avgMin: 0, avgMax: 1)
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
        fetch()
    }
    
    func fetch() -> Void {
        DispatchQueue.main.async {
            self.getStatEntries { result in
                switch result {
                case .success(let statsEntries):
                    self.stats = statsEntries
                case .failure(let error):
                    print("error while fetching stats")
                    print(error)
                }
            }
        }
    }
    
    private func getStatEntries(completion: @escaping (Result<StatsEntries, Error>) -> Void) {
        self.apiManager.fetchStatsData { result in
            switch result {
            case .success(let entries):
                var statsNormal: [StatsEntries.Entry] = []
                //                var statsGroupedByHourNormal: [StatsModel] = []
                var statsFast: [StatsEntries.Entry] = []
                //                var statsGroupedByHourFast: [StatsModel] = []

                for (_, statModel) in entries {
                    let entry = StatsEntries.Entry(
                        minuteOfDay: statModel.minuteOfDay, max: statModel.max, avg: statModel.avg, min: statModel.min, measureName: statModel.measureName
                    )
                    if statModel.measureName == "normal" {
                        statsNormal.append(entry)
                    } else if statModel.measureName == "fast" {
                        statsFast.append(entry)
                    }
                }
                statsNormal.sort(by: { $0.minuteOfDay < $1.minuteOfDay })

                var statsGroupedByHourNormal = groupByHour(stats: statsNormal)

                var avgMin:Double {
                    return statsGroupedByHourNormal.map { $0.avg }.min() ?? 0.0 - 1
                }

                var avgMax:Double {
                    return statsGroupedByHourNormal.map { $0.avg }.max() ?? 0.0 + 1
                }

                statsGroupedByHourNormal.sort(by: { $0.minuteOfDay < $1.minuteOfDay })
                let statsGroupedByHourFast = groupByHour(stats: statsFast)
                let statsEntries = StatsEntries(statsNormal: statsNormal, statsGroupedByHourNormal: statsGroupedByHourNormal, statsFast: statsFast, statsGroupedByHourFast: statsGroupedByHourFast, timestamp: Date(), avgMin: avgMin, avgMax: avgMax)

                completion(.success(statsEntries))

            case .failure(let error):
                print("Error Fetching Stats \(error)")
                completion(.failure(error))
            }
        }
    }
}

func groupByHour(stats: [StatsEntries.Entry]) -> [StatsEntries.Entry] {
    var groupedStats: [Int: [StatsEntries.Entry]] = [:]
    var averagedStats: [StatsEntries.Entry] = []

    for stat in stats {
        let hour = stat.minuteOfDay / 60
        groupedStats[hour, default: []].append(stat)
    }

    for (hour, stats) in groupedStats {
        let totalStats = stats.count
        var avgMax:Double = 0
        var avgAvg:Double = 0
        var avgMin:Double = 0

        for stat in stats {
            avgMax += stat.max
            avgAvg += stat.avg
            avgMin += stat.min
        }

        avgMax /= Double(totalStats)
        avgAvg /= Double(totalStats)
        avgMin /= Double(totalStats)

        let averagedStat = StatsEntries.Entry(minuteOfDay: hour, max: avgMax, avg: avgAvg, min: avgMin, measureName: "average_by_hour")
        averagedStats.append(averagedStat)
    }

    return averagedStats
}

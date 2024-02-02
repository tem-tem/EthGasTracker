////
////  DataManager.swift
////  EthGasTracker
////
////  Created by Tem on 8/5/23.
////
//
//import Foundation
//import CoreData
//
//
//struct LegacyGasData {
//    var low:Double;
//    var avg:Double;
//    var high:Double;
//}
//
//
//struct LegacyGasIndexEntity {
//    let entries: [String: LegacyGasData]
//}
//
//struct NormalizedEntities {
//    var actionEntities: [String: [ActionEntity]]
//    var gasIndexEntity: GasIndexEntity
//    var ethPriceEntity: PriceDataEntity
//    var legacyGasIndexEntity: LegacyGasIndexEntity
//}
//
//struct StatsEntries {
//    let statsNormal: [Entry]
//    let statsGroupedByHourNormal: [Entry]
//    let statsFast: [Entry]
//    let statsGroupedByHourFast: [Entry]
//    let timestamp: Date
//    
//    let avgMin:Double
//    let avgMax:Double
//    
//    struct Entry {
//        let minuteOfDay: Int
//        let max:Double
//        let avg:Double
//        let min:Double
//        let measureName: String
//    }
//}
//
//class DataManager: ObservableObject {
//    let api_v1: API_v1
//    
//    init() {
//        self.api_v1 = API_v1()
//    }
//    
//    func getStatEntries(completion: @escaping (Result<StatsEntries, Error>) -> Void) {
//        self.api_v1.fetchStatsData { result in
//            switch result {
//            case .success(let entries):
//                var statsNormal: [StatsEntries.Entry] = []
//                //                var statsGroupedByHourNormal: [StatsModel] = []
//                var statsFast: [StatsEntries.Entry] = []
//                //                var statsGroupedByHourFast: [StatsModel] = []
//                
//                for (_, statModel) in entries {
//                    let entry = StatsEntries.Entry(
//                        minuteOfDay: statModel.minuteOfDay, max: statModel.max, avg: statModel.avg, min: statModel.min, measureName: statModel.measureName
//                    )
//                    if statModel.measureName == "normal" {
//                        statsNormal.append(entry)
//                    } else if statModel.measureName == "fast" {
//                        statsFast.append(entry)
//                    }
//                }
//                statsNormal.sort(by: { $0.minuteOfDay < $1.minuteOfDay })
//                
//                var statsGroupedByHourNormal = groupByHour(stats: statsNormal)
//                
//                var avgMin:Double {
//                    return statsGroupedByHourNormal.map { $0.avg }.min() ?? 0.0 - 1
//                }
//                
//                var avgMax:Double {
//                    return statsGroupedByHourNormal.map { $0.avg }.max() ?? 0.0 + 1
//                }
//                
//                statsGroupedByHourNormal.sort(by: { $0.minuteOfDay < $1.minuteOfDay })
//                let statsGroupedByHourFast = groupByHour(stats: statsFast)
//                let statsEntries = StatsEntries(statsNormal: statsNormal, statsGroupedByHourNormal: statsGroupedByHourNormal, statsFast: statsFast, statsGroupedByHourFast: statsGroupedByHourFast, timestamp: Date(), avgMin: avgMin, avgMax: avgMax)
//                
//                completion(.success(statsEntries))
//                
//            case .failure(let error):
//                print("Error Fetching Stats \(error)")
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    func getEntities(amount: Int, actions: String, completion: @escaping (Result<NormalizedEntities, Error>) -> Void) {
//        api_v1.fetchLatestData(amount: amount, actions: actions) { result in
//            switch result {
//            case .success(let response):
//                let normalizedEntities = self.normalize(response: response)
//                completion(.success(normalizedEntities))
//            case .failure(let error):
//                print("Error Fetching \(error)")
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    private func normalize(response: ApiV1Response) -> NormalizedEntities {
//        var gasIndexEntity = GasDataEntity(entries: [:])
//        var ethPriceEntity = PriceDataEntity(entries: [:])
//        var legacyGasIndexEntity: LegacyGasIndexEntity = LegacyGasIndexEntity(entries: [:])
//        
//        for (index, rawEntity) in response.indexes {
//            if (index == "gas") {
//                var entries: [String: NormalFast] = [:]
//                for (timestamp, entry) in rawEntity.entries {
//                    entries[timestamp] = NormalFast(normal:Double(entry.normal!)!, fast:Double(entry.fast!)!)
//                }
//                gasIndexEntity = GasDataEntity(entries: entries)
//            }
//            if (index == "eth_price") {
//                var entries: [String: PriceData] = [:]
//                for (timestamp, entry) in rawEntity.entries {
//                    entries[timestamp] = PriceData(price:Double(entry.price!)!)
//                }
//                ethPriceEntity = PriceDataEntity(entries: entries)
//            }
//            
//            if (index == "etherscan_gas_oracle") {
//                var entries: [String: LegacyGasData] = [:]
//                for (timestamp, entry) in rawEntity.entries {
//                    guard entry.low != nil && entry.low!.count > 0 else {
//                        continue
//                    }
//                    entries[timestamp] = LegacyGasData(low:Double(entry.low!)!, avg:Double(entry.avg!)!, high:Double(entry.high!)!)
//                }
//                legacyGasIndexEntity = LegacyGasIndexEntity(entries: entries)
//            }
//        }
//        
//        var actionEntities: [String: [ActionEntity]] = groupActions(
//            actions: response.actions,
//            gasIndexEntity: gasIndexEntity,
//            ethPriceEntity: ethPriceEntity
//        )
//        
//        return NormalizedEntities(actionEntities: actionEntities, gasIndexEntity: gasIndexEntity, ethPriceEntity: ethPriceEntity, legacyGasIndexEntity: legacyGasIndexEntity)
//    }
//    
//    private func groupActions(
//        actions: [String: ApiV1Response.Action],
//        gasIndexEntity: GasDataEntity,
//        ethPriceEntity: PriceDataEntity
//    ) -> [String: [ActionEntity]] {
//        var actionEntities: [String: [ActionEntity]] = [:]
//        for (_, rawAction) in actions {
//            let actionEntity = normalizeAction(
//                rawAction: rawAction,
//                gasIndexEntity: gasIndexEntity,
//                ethPriceEntity: ethPriceEntity
//            )
//            
//            if actionEntities[rawAction.metadata.groupName] == nil {
//                actionEntities[rawAction.metadata.groupName] = []
//            }
//            
//            actionEntities[rawAction.metadata.groupName]?.append(actionEntity)
//        }
//        
//        return actionEntities
//    }
//    
//    private func normalizeAction(
//        rawAction: ApiV1Response.Action,
//        gasIndexEntity: GasDataEntity,
//        ethPriceEntity: PriceDataEntity
//    ) -> ActionEntity {
//        let metadata = Metadata(
//            name: rawAction.metadata.name,
//            groupName: rawAction.metadata.groupName,
//            key: rawAction.metadata.key,
//            limit: rawAction.metadata.limit
//        )
//        
//        var entries: [String: NormalFast] = [:]
//        for (timestamp, gasEntry) in gasIndexEntity.entries {
//            
//            let normal = (Double(String(format: "%.6f", (gasEntry.normal * Double(metadata.limit)) / 1e9)) ?? 0) * (ethPriceEntity.entries[timestamp]?.price ?? 0)
//            let fast = (Double(String(format: "%.6f", (gasEntry.fast * Double(metadata.limit)) / 1e9)) ?? 0) * (ethPriceEntity.entries[timestamp]?.price ?? 0)
//            
//            entries[timestamp] = NormalFast(normal: normal, fast: fast)
//        }
//        
//        let actionEntity = ActionEntity(entries: entries, metadata: metadata)
//        return actionEntity
//    }
//}
//
//
//
//func groupByHour(stats: [StatsEntries.Entry]) -> [StatsEntries.Entry] {
//    var groupedStats: [Int: [StatsEntries.Entry]] = [:]
//    var averagedStats: [StatsEntries.Entry] = []
//    
//    for stat in stats {
//        let hour = stat.minuteOfDay / 60
//        groupedStats[hour, default: []].append(stat)
//    }
//    
//    for (hour, stats) in groupedStats {
//        let totalStats = stats.count
//        var avgMax:Double = 0
//        var avgAvg:Double = 0
//        var avgMin:Double = 0
//        
//        for stat in stats {
//            avgMax += stat.max
//            avgAvg += stat.avg
//            avgMin += stat.min
//        }
//        
//        avgMax /= Double(totalStats)
//        avgAvg /= Double(totalStats)
//        avgMin /= Double(totalStats)
//        
//        let averagedStat = StatsEntries.Entry(minuteOfDay: hour, max: avgMax, avg: avgAvg, min: avgMin, measureName: "average_by_hour")
//        averagedStats.append(averagedStat)
//    }
//    
//    return averagedStats
//}

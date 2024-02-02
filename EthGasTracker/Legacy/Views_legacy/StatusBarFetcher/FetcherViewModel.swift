//
//  FetcherViewModel.swift
//  EthGasTracker
//
//  Created by Tem on 3/15/23.
//

import Foundation
import Combine
import SwiftUI

enum FetchStatus {
    case idle
    case fetching
    case success
    case failure(Error)
}

let CHART_RANGE = 12

class FetcherViewModel: ObservableObject {
    @Published var status: FetchStatus = .idle
    @Published var gasList: [GasData] = [] {
        didSet {
            saveGasDataListToUserDefaults()
        }
    }
    @Published var stats: [Stat] = [] {
        didSet {
            saveStatsToUserDefaults()
        }
    }
    
    @AppStorage("LastBlock") var lastBlock: String = ""
    @AppStorage("SafeGasPrice") var safeGasPrice: String = ""
    @AppStorage("ProposeGasPrice") var proposeGasPrice: String = ""
    @AppStorage("FastGasPrice") var fastGasPrice: String = ""
    @AppStorage("suggestBaseFee") var suggestBaseFee: String = ""
    @AppStorage("gasUsedRatio") var gasUsedRatio: String = ""
    @AppStorage("timestamp") var timestamp: Int = 0
    @AppStorage("lastUpdate") var lastUpdate: Double = 0
    
    @AppStorage("avgMin") var avgMin: Double = 0.0
    @AppStorage("avgMax") var avgMax: Double = 9999.0
    @AppStorage("highMin") var highMin: Double = 0.0
    @AppStorage("highMax") var highMax: Double = 9999.0
    @AppStorage("lowMin") var lowMin: Double = 0.0
    @AppStorage("lowMax") var lowMax: Double = 9999.0
    @AppStorage("minIn48Stats") var minIn48Stats: Double?
    @AppStorage("maxIn48Stats") var maxIn48Stats: Double?
    @AppStorage("minInAllStats") var minInAllStats: Double?
    @AppStorage("maxInAllStats") var maxInAllStats: Double?
    
    @AppStorage("dataUpdateToggle") var dataUpdateToggle = false
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    private let api = MyAPI()

    init() {
        loadGasDataListFromUserDefaults()
        startTimer()
        loadStatsFromUserDefaults()
        fetchStatsOnAppear()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.fetchData()
            self?.fetchStatsOnAppear()
        }
    }
    
    func fetchData() {
        status = .fetching
        
        api.fetchGasList { [weak self] response, error in
            if let error = error {
                self?.status = .failure(error)
                return
            }
            
            guard let gasListData = response?.gas_list else {
                self?.status = .failure(NSError(domain: "Invalid response", code: 0, userInfo: nil))
                return
            }
            
            // Update the @Published property on the main thread
            DispatchQueue.main.async {
                self?.gasList = gasListData
                self?.status = .idle
                
                self?.lastBlock = gasListData.first?.LastBlock ?? "0"
                self?.safeGasPrice = gasListData.first?.SafeGasPrice ?? "0"
                self?.proposeGasPrice = gasListData.first?.ProposeGasPrice ?? "0"
                self?.fastGasPrice = gasListData.first?.FastGasPrice ?? "0"
                self?.suggestBaseFee = gasListData.first?.suggestBaseFee ?? "0"
                self?.timestamp = gasListData.first?.timestamp ?? 0
                
                let minMaxAverage = getMinMax(from: gasListData, keyPath: \.ProposeGasPrice)
                self?.avgMin = minMaxAverage.min ?? 9999.9
                self?.avgMax = minMaxAverage.max ?? 0.0
                
                let minMaxHigh = getMinMax(from: gasListData, keyPath: \.FastGasPrice)
                self?.highMin = minMaxHigh.min ?? 9999.9
                self?.highMax = minMaxHigh.max ?? 0.0
                
                let minMaxLow = getMinMax(from: gasListData, keyPath: \.SafeGasPrice)
                self?.lowMin = minMaxLow.min ?? 9999.9
                self?.lowMax = minMaxLow.max ?? 0.0
                
                self?.dataUpdateToggle.toggle()
            }
        }
    }
    
    private func saveGasDataListToUserDefaults() {
        if let encodedGasDataList = try? JSONEncoder().encode(gasList) {
            UserDefaults.standard.setValue(encodedGasDataList, forKey: gasListKey)
        }
    }
    
    private func loadGasDataListFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: gasListKey),
           let decodedGasDataList = try? JSONDecoder().decode([GasData].self, from: data) {
            gasList = decodedGasDataList
        }
    }
    
    func fetchStatsOnAppear() {
        if (stats.count > 0) {
            guard let latestTimestamp = stats.last?.timestamp_utc else {
                return
            }
            guard let latestStatDate = dateStringToDate(latestTimestamp) else {
                return
            }
            
            let currentTimestampUTC = Double(currentUTCTimestamp())
            guard currentTimestampUTC - latestStatDate.timeIntervalSince1970 > 3600 else {
                return
            }
            updateStats()
        } else {
            updateStats()
        }
    }
    
    private func updateStats() -> Void {
        api.fetchStats { [weak self] result, error in
            if let error = error {
                print("Error fetching stats: \(error.localizedDescription)")
                return
            }
            
            guard let statsData = result?.stats else {
                print("Invalid stats response")
                return
            }
            
            DispatchQueue.main.async {
//                calc stats using raw data
                self?.maxIn48Stats = statsData.prefix(48).max { $0.average_gas_price < $1.average_gas_price }?.average_gas_price
                self?.minIn48Stats = statsData.prefix(48).min { $0.average_gas_price < $1.average_gas_price }?.average_gas_price
                self?.maxInAllStats = statsData.max { $0.average_gas_price < $1.average_gas_price }?.average_gas_price
                self?.minInAllStats = statsData.min { $0.average_gas_price < $1.average_gas_price }?.average_gas_price
                
//                normalize data for presentations
                let startHour = lastIndexWithZeroHours(stats: statsData)
                self?.stats = normalizeStats(stats: Array(statsData.prefix(startHour ?? statsData.count)))
            }
        }
    }
    
    private func currentUTCTimestamp() -> Int {
        let currentDate = Date()
        let utcTimestamp = Int(currentDate.timeIntervalSince1970)
        
        return utcTimestamp
    }
    
    private func dateStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        return dateFormatter.date(from: dateString)
    }

    private func saveStatsToUserDefaults() {
        if let encodedStats = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.setValue(encodedStats, forKey: statsKey)
        }
    }
    
    private func loadStatsFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decodedStats = try? JSONDecoder().decode([Stat].self, from: data) {
            stats = decodedStats
        }
    }


    deinit {
        timer?.invalidate()
    }
}

func getMinMax(from gasPrices: [GasData], keyPath: KeyPath<GasData, String>) -> (min: Double?, max: Double?) {
    guard let initialGasPrice = gasPrices.first else {
        return (min: 0, max: 0)
    }

    let minMax = gasPrices.prefix(CHART_RANGE).reduce((min: Double(initialGasPrice[keyPath: keyPath]), max: Double(initialGasPrice[keyPath: keyPath]))) { (currentMinMax, gasPrice) -> (Double, Double) in
        let currentMin = currentMinMax.min
        let currentMax = currentMinMax.max
        let newMin = min(currentMin ?? 0, Double(gasPrice[keyPath: keyPath]) ?? 0)
        let newMax = max(currentMax ?? 0, Double(gasPrice[keyPath: keyPath]) ?? 0)

        return (min: newMin , max: newMax )
    }

    return minMax
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

func normalizeStats(stats: [Stat]) -> [Stat] {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    let calendar = Calendar.current
//    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    var statsDict = [Date: Double]()
    
    for stat in stats {
        if let date = formatter.date(from: stat.timestamp_utc) {
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            if let normalizedDate = calendar.date(from: components) {
                statsDict[normalizedDate] = stat.average_gas_price
            }
        }
    }

    guard let minDate = statsDict.keys.min(), let maxDate = statsDict.keys.max() else {
        return stats
    }
    
    var currentDate = minDate
    let endDate = maxDate
    var normalizedStats = [Stat]()

    while currentDate <= endDate {
        if let value = statsDict[currentDate] {
            let newStat = Stat(average_gas_price: value, timestamp_utc: formatter.string(from: currentDate))
            normalizedStats.append(newStat)
        } else {
            let newStat = Stat(average_gas_price: 0.0, timestamp_utc: formatter.string(from: currentDate))
            normalizedStats.append(newStat)
        }
        
        currentDate = calendar.date(byAdding: .hour, value: 1, to: currentDate)!
    }
    
    return normalizedStats
}


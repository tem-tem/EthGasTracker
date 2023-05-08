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
    @AppStorage("minInStats") var minInStats: Double?
    @AppStorage("maxInStats") var maxInStats: Double?
    
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
//        let latestTimestamp = stats.first?.timestamp_utc
        if (stats.count > 0) {
            guard let latestTimestamp = stats.first?.timestamp_utc else {
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
                self?.stats = statsData
                
                self?.maxInStats = statsData.max { $0.average_gas_price < $1.average_gas_price }?.average_gas_price
                self?.minInStats = statsData.min { $0.average_gas_price < $1.average_gas_price }?.average_gas_price
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


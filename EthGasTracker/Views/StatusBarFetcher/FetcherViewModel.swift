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
    @AppStorage("LastBlock") var lastBlock: String = ""
    @AppStorage("SafeGasPrice") var safeGasPrice: String = ""
    @AppStorage("ProposeGasPrice") var proposeGasPrice: String = ""
    @AppStorage("FastGasPrice") var fastGasPrice: String = ""
    @AppStorage("suggestBaseFee") var suggestBaseFee: String = ""
    @AppStorage("gasUsedRatio") var gasUsedRatio: String = ""
    @AppStorage("timestamp") var timestamp: Int = 0
    @AppStorage("lastUpdate") var lastUpdate: Double = 0
    
    @AppStorage("ethbtc") var ethbtc: String = ""
    @AppStorage("ethbtc_timestamp") var ethbtc_timestamp: String = ""
    @AppStorage("ethusd") var ethusd: String = ""
    @AppStorage("ethusd_timestamp") var ethusd_timestamp: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    private let api = MyAPI() // replace with your own API client
//    private let storage = MyStorage() // replace with your own storage solution

    init() {
        fetchData()
        startTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.fetchData()
        }
    }
    
    func fetchData() {
        status = .fetching
        
        api.fetchGas { [weak self] response, error in
            if let error = error {
                self?.status = .failure(error)
                return
            }
            
            guard let gasData: GasData = response?.gasData else {
                self?.status = .failure(NSError(domain: "Invalid response", code: 0, userInfo: nil))
                return
            }
            
            
            guard let ethData: EthData = response?.ethPrice else {
                self?.status = .failure(NSError(domain: "Invalid response", code: 0, userInfo: nil))
                return
            }
            
            // Update the @AppStorage properties on the main thread
            DispatchQueue.main.async {
                self?.lastBlock = gasData.LastBlock
                self?.safeGasPrice = gasData.SafeGasPrice
                self?.proposeGasPrice = gasData.ProposeGasPrice
                self?.fastGasPrice = gasData.FastGasPrice
                self?.suggestBaseFee = gasData.suggestBaseFee
                self?.timestamp = gasData.timestamp
                self?.gasUsedRatio = self?.calculateAverage(numbersString: gasData.gasUsedRatio) ?? "..."
                
                self?.ethbtc = ethData.ethbtc
                self?.ethusd = ethData.ethusd
                self?.ethbtc_timestamp = ethData.ethbtc_timestamp
                self?.ethusd_timestamp = ethData.ethusd_timestamp
                
                self?.lastUpdate = Date().timeIntervalSince1970
                
                self?.status = .idle
            }
        }
    }
    
    private func calculateAverage(numbersString: String) -> String? {
        let numbers = numbersString.split(separator: ",")
                                   .compactMap { Float($0) }
        guard !numbers.isEmpty else { return nil }
        let average = numbers.reduce(0, +) / Float(numbers.count)
        return String(format: "%.2f", average)
    }


    deinit {
        timer?.invalidate()
    }
}

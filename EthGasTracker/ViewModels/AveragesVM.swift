//
//  AveragesVM.swift
//  EthGasTracker
//
//  Created by Tem on 10/21/24.
//

import Foundation
import Combine

class AveragesViewModel: ObservableObject {
    // Cache now stores an array of AverageEntry objects, keyed by CacheKey (range, weekday)
    @Published var averagesData: [CacheKey: [AverageEntry]] = [:]
    @Published var errorMessage: String? = nil
    private var cancellables = Set<AnyCancellable>()

    // APIManager instance for fetching data
    private let apiManager: APIManager

    // Custom type for caching keys, with AveragesRange and optional weekday
    struct CacheKey: Hashable {
        let range: AveragesRange
        let weekday: AveragesWeekday?
    }

    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }

    // Fetch averages data, differentiating between range with and without weekday
    func fetchAverages(for range: AveragesRange, weekday: AveragesWeekday? = nil, completion: @escaping (Result<[AverageEntry], Error>) -> Void) {
        let cacheKey = CacheKey(range: range, weekday: weekday)

        // Check if data is already cached
        if let cachedData = averagesData[cacheKey] {
            print("Using cached data for range \(range.rawValue), weekday \(String(describing: weekday))")
            completion(.success(cachedData))
            return
        }

        // Fetch data using APIManager
        apiManager.getAverages(range: range, weekday: weekday) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let averagesResponse):
                    // Sort the AverageEntry objects by minuteOfDay
                    let sortedAveragesArray = averagesResponse.averages.values.sorted {
                        $0.minuteOfDay < $1.minuteOfDay
                    }

                    // Store the sorted array in the cache
                    self?.averagesData[cacheKey] = sortedAveragesArray
                    print("Data for range \(range.rawValue), weekday \(String(describing: weekday)) fetched and sorted successfully")
                    completion(.success(sortedAveragesArray))
                    
                case .failure(let error):
                    self?.errorMessage = "Failed to load data: \(error.localizedDescription)"
                    print("Failed to fetch data for range \(range.rawValue), weekday \(String(describing: weekday)): \(error)")
                    completion(.failure(error))
                }
            }
        }
    }

    // Retrieve cached averages for the specific range and optional weekday
    func getAverages(for range: AveragesRange, weekday: AveragesWeekday? = nil) -> [AverageEntry]? {
        let cacheKey = CacheKey(range: range, weekday: weekday)
        return averagesData[cacheKey]
    }

    // Clear the entire cache
    func clearCache() {
        averagesData.removeAll()
    }
}


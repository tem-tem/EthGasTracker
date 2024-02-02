//
//  APIManager_StatsData.swift
//  EthGasTracker
//
//  Created by Tem on 1/29/24.
//

import Foundation

extension APIManager {
    
    func fetchStatsData(completion: @escaping (Result<[String: StatsModel], Error>) -> Void) {
        let urlString = endpoints.stats

        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            }
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                }
                return
            }

            do {
                let apiResponse = try JSONDecoder().decode(ApiV1StatsResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(apiResponse.stats))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

struct ApiV1StatsResponse: Decodable {
    let stats: [String: StatsModel]
}

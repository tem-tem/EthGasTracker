//
//  APIManager_GetLatestData.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

extension APIManager {
    func getLiveData(currency: String,  completion: @escaping (Result<LiveDataResponse, Error>) -> Void) {
        let currencyParam = currency == "USD" ? "" : "&currency=" + currency
        guard let url = URL(string: endpoints.latest + currencyParam) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(LiveDataResponse.self, from: data)
                completion(.success(response))
            } catch let decodeError {
                completion(.failure(decodeError))
            }
        }
        task.resume()
    }
}

//
//  APIManager+Averages.swift
//  EthGasTracker
//
//  Created by Tem on 10/21/24.
//

import Foundation


extension APIManager {
    func getAverages(range: AveragesRange, weekday: AveragesWeekday?, completion: @escaping (Result<AveragesResponse, Error>) -> Void) {
        let stringUrl = endpoints.averages(range, weekday)
        print("fetching averages for \(stringUrl)")
        guard let url = URL(string: stringUrl) else {
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
                let response = try decoder.decode(AveragesResponse.self, from: data)
                completion(.success(response))
            } catch let decodeError {
                completion(.failure(decodeError))
            }
        }
        
        task.resume()
    }
}

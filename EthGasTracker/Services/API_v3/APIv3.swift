//
//  APIv2.swift
//  EthGasTracker
//
//  Created by Tem on 11/5/23.
//

import Foundation

class APIv3 {
    func getLatest(currency: String,  completion: @escaping (Result<APIv3_GetLatestResponse, Error>) -> Void) {
        let currencyParam = currency == "USD" ? "" : "&currency=" + currency
        guard let url = URL(string: Endpoints().latest + currencyParam) else {
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
                let response = try decoder.decode(APIv3_GetLatestResponse.self, from: data)
                completion(.success(response))
            } catch let decodeError {
                completion(.failure(decodeError))
            }
        }
        task.resume()
    }
}

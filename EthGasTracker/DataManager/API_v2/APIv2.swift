//
//  APIv2.swift
//  EthGasTracker
//
//  Created by Tem on 11/5/23.
//

import Foundation

class Endpoints {
//    let env = ""
    let PROD = "http://135.181.194.46:8080"
    let DEV = "http://127.0.0.1:8080"
    let AMOUNT_TO_FETCH = 90

//    let baseURL: String
    let latest: String
    
    init () {
        let env = self.PROD
        self.latest = env + "/api/v2/latest" + "?amount=" + String(AMOUNT_TO_FETCH)
    }
}

class APIv2 {
    func getLatest(completion: @escaping (Result<APIv2_GetLatestResponse, Error>) -> Void) {
        guard let url = URL(string: Endpoints().latest) else {
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
                let response = try decoder.decode(APIv2_GetLatestResponse.self, from: data)
                completion(.success(response))
            } catch let decodeError {
                completion(.failure(decodeError))
            }
        }
        task.resume()
    }
}

enum APIError: Error {
    case invalidURL
    case noData
}

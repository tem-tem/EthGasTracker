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
    let historyHour: String
    let historyDay: String
    let historyWeek: String
    let historyMonth: String
    
    init () {
        let env = self.PROD
        self.latest = env + "/api/v3/latest" + "?amount=" + String(AMOUNT_TO_FETCH)
        self.historyHour =  env + "/api/v3/history/hour"
        self.historyDay =  env + "/api/v3/history/day"
        self.historyWeek =  env + "/api/v3/history/week"
        self.historyMonth =  env + "/api/v3/history/month"
    }
}

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

enum APIError: Error {
    case invalidURL
    case noData
}

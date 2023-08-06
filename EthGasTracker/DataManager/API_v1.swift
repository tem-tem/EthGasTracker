//
//  API_v1.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import Foundation

class API_v1 {
    let baseLink: String = "http://localhost:8000"
    let endpoint: String = "/api/v1/latest"
    
    func fetchLatestData(amount: Int, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let urlString = "\(baseLink)\(endpoint)?amount=\(amount)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

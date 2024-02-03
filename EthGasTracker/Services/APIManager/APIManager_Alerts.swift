//
//  APIManager_Alerts.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import Foundation

extension APIManager {
    func getAlerts(by deviceId: String, completion: @escaping (Result<[Alert], Error>) -> Void) {
        let urlString = "\(endpoints.getAlerts)?deviceId=\(deviceId)" // Update with the appropriate endpoint
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let alerts = try JSONDecoder().decode([Alert].self, from: data)
                completion(.success(alerts))
            } catch {
                print("Error decoding \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func addAlert(_ alert: Alert, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = endpoints.addAlert
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        do {
            let jsonData = try JSONEncoder().encode(alert)
            request.httpBody = jsonData
        } catch {
            print("Error encoding \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let response = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "No data or incorrect format", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(response))
        }.resume()
    }
    
    func toggleAlert(by alertId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(endpoints.toggleAlert)?alertId=\(alertId)" // Update with the appropriate endpoint

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT" // Assuming a PUT request to toggle the alert
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Unexpected response", code: 0, userInfo: nil)))
                return
            }

            completion(.success(()))
        }.resume()
    }

    func deleteAlert(by alertId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(endpoints.deleteAlert)?alertId=\(alertId)" // Update with the appropriate endpoint

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Unexpected response", code: 0, userInfo: nil)))
                return
            }

            completion(.success(()))
        }.resume()
    }
    
    func updateAlert(_ alert: Alert, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = endpoints.updateAlert
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        do {
            let jsonData = try JSONEncoder().encode(alert)
            request.httpBody = jsonData
        } catch {
            print("Error encoding \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Unexpected response", code: 0, userInfo: nil)))
                return
            }

            completion(.success(()))
        }.resume()
    }
}

//
//  API_v1.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import Foundation

struct ApiV1Response: Codable {
    let actions: [String: Action]
    let indexes: [String: Index]
    
    struct Action: Codable {
        let entries: [String: ActionData]
        let metadata: ActionMetadata
    }
    
    struct ActionData: Codable {
        let normal: String
        let fast: String
    }
    
    struct ActionMetadata: Codable {
        let name: String
        let groupName: String
        let key: String
        let limit: Int64
    }
    
    struct Index: Codable {
        let entries: [String: IndexData]
        let metadata: IndexMetadata
    }
    
    struct IndexData: Codable {
        let price: String?
        let normal: String?
        let fast: String?
        let low: String?
        let avg: String?
        let high: String?
    }
    
    struct IndexMetadata: Codable {
        let name: String
    }
}

struct API_v1_Response_Entity: Codable {
    let data: [String: EntityData]
    let metadata: Metadata

    struct EntityData: Codable {
    }


    struct Metadata: Codable {
        let name: String
        let type: DataType
    }
    
    enum DataType: String, Codable {
        case index
        case action
    }
}

struct GasAlert: Codable, Identifiable { // Conform to both Encodable and Decodable
    let id: String? // ID property is now optional
    let deviceId: String
    let mutePeriod: Int
    let conditions: [Condition]
    let confirmationPeriod: Int
    let legacyGas: Bool?
    var disabled: Bool?
    var disableAfterAlerts: Int?
    
    
    struct Condition: Codable { // Conform to both Encodable and Decodable
        let comparison: Comparison
        let value: Int
        
        enum Comparison: String, Codable, CaseIterable {
            case greater_than
            case greater_than_or_equal
            case less_than
            case less_than_or_equal
        }
    }
}

struct ApiV1StatsResponse: Decodable {
    let stats: [String: StatsModel]
}

struct StatsModel: Decodable {
    let minuteOfDay: Int
    let max: Float
    let avg: Float
    let min: Float
    let measureName: String

    enum CodingKeys: String, CodingKey {
        case minuteOfDay = "minute_of_day"
        case max, avg, min, measureName = "measure_name"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let minuteOfDayStr = try container.decode(String.self, forKey: .minuteOfDay)
        guard let minuteAsInt = Int(minuteOfDayStr) else {
            throw DecodingError.dataCorruptedError(forKey: .minuteOfDay, in: container, debugDescription: "Minute of day couldn't be converted to Int")
        }
        minuteOfDay = minuteAsInt

        let maxStr = try container.decode(String.self, forKey: .max)
        guard let maxAsFloat = Float(maxStr) else {
            throw DecodingError.dataCorruptedError(forKey: .max, in: container, debugDescription: "Max couldn't be converted to Float")
        }
        max = maxAsFloat

        let avgStr = try container.decode(String.self, forKey: .avg)
        guard let avgAsFloat = Float(avgStr) else {
            throw DecodingError.dataCorruptedError(forKey: .avg, in: container, debugDescription: "Avg couldn't be converted to Float")
        }
        avg = avgAsFloat

        let minStr = try container.decode(String.self, forKey: .min)
        guard let minAsFloat = Float(minStr) else {
            throw DecodingError.dataCorruptedError(forKey: .min, in: container, debugDescription: "Min couldn't be converted to Float")
        }
        min = minAsFloat

        measureName = try container.decode(String.self, forKey: .measureName)
    }
}

struct ServerMessagesResponse: Decodable {
    let server_messages: [String: ServerMessage]
}

struct ServerMessage: Decodable {
    let title: String
    let body: String
    let url: String
    let image: String
}


let PROD = "http://135.181.194.46:8080"
let DEV = "http://127.0.0.1:8080"

let baseLink: String = PROD
let latestEndpoint: String = "/api/v1/latest"
let statsEndpoint: String = "/api/v1/stats"
let messagesEndpoint: String = "/api/v1/messages"
let addAlertEndpoint: String = "/api/v1/alerts/add"
let getAlertsEndpoint: String = "/api/v1/alerts/list"
let toggleAlertEndpoint: String = "/api/v1/alerts/toggle"
let deleteAlertEndpoint: String = "/api/v1/alerts/delete"

class API_v1 {
    
    func fetchServerMessages(completion: @escaping (Result<[ServerMessage], Error>) -> Void) {
        let urlString = "\(baseLink)\(messagesEndpoint)"

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
                let response = try JSONDecoder().decode(ServerMessagesResponse.self, from: data)
                let messages = Array(response.server_messages.values)
                DispatchQueue.main.async {
                    completion(.success(messages))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchLatestData(amount: Int, completion: @escaping (Result<ApiV1Response, Error>) -> Void) {
        let urlString = "\(baseLink)\(latestEndpoint)?amount=\(amount)"

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
                let response = try JSONDecoder().decode(ApiV1Response.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    
    func fetchStatsData(completion: @escaping (Result<[String: StatsModel], Error>) -> Void) {
        let urlString = "\(baseLink)\(statsEndpoint)"

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

    
    func addAlert(_ alert: GasAlert, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "\(baseLink)\(addAlertEndpoint)"
        
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
    
    func getAlerts(by deviceId: String, completion: @escaping (Result<[GasAlert], Error>) -> Void) {
        let urlString = "\(baseLink)\(getAlertsEndpoint)?deviceId=\(deviceId)" // Update with the appropriate endpoint
        
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
            if let jsonString = String(data: data, encoding: .utf8) {
                print("*********")
                print(jsonString)
            } else {
                print("Failed to convert data to string")
            }
            do {
                let alerts = try JSONDecoder().decode([GasAlert].self, from: data)
                completion(.success(alerts))
            } catch {
                print("Error decoding \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    func toggleAlert(by alertId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseLink)\(toggleAlertEndpoint)?alertId=\(alertId)" // Update with the appropriate endpoint

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
        let urlString = "\(baseLink)\(deleteAlertEndpoint)?alertId=\(alertId)" // Update with the appropriate endpoint

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

}

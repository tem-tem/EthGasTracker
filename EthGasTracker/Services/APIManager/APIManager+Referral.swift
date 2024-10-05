//
//  APIManager+Referral.swift
//  EthGasTracker
//
//  Created by Tem on 9/29/24.
//

import Foundation

extension APIManager {
    // MARK: - Create User and Fetch Referral Code
    func createUser(secret: String, completion: @escaping (Result<CreatedUserResponse, Error>) -> Void) {
        guard let url = URL(string: Endpoints().getReferralCode) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create request body with the secret
        let requestBody = CreateUserRequest(secret: secret)
        
        do {
            let data = try JSONEncoder().encode(requestBody)
            request.httpBody = data
        } catch {
            completion(.failure(error))
            return
        }
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Response: \(String(describing: response))")
            print("Data: \(String(data: data!, encoding: .utf8)!)")
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let createdUser = try JSONDecoder().decode(CreatedUserResponse.self, from: data)
                completion(.success(createdUser))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Apply Referral
    func applyReferral(requestBody: ReferralRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: endpoints.applyReferral) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let data = try JSONEncoder().encode(requestBody)
            request.httpBody = data
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
//            print("DATA: \(String(data: data, encoding: .utf8)!)")
            if let error = error {
                print("ERROR DURING APPLY REFERRAL: \(error)")
                print("RESPONSE: \(String(describing: response))")
                completion(.failure(error))
                return
            }
            
            let responseStatusCode = (response as! HTTPURLResponse).statusCode
            print("RESPONSE STATUS CODE: \(responseStatusCode)")
            
            if (500...599).contains(responseStatusCode) {
                completion(.failure(
                    NSError(
                        domain: "",
                        code: responseStatusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Something went wrong. Please try again later."]
                    )
                ))
                return
            }
            
            if (400...499).contains(responseStatusCode) {
                completion(.failure(
                    NSError(
                        domain: "",
                        code: responseStatusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Code not found"]
                    )
                ))
                return
            }
            
            completion(.success(true))
        }.resume()
    }

    // MARK: - Get Referral Points
    func getReferralPoints(requestBody: ReferralPointsRequest, completion: @escaping (Result<ReferralResponse, Error>) -> Void) {
        let urlStr = endpoints.getReferralPoints
        guard let url = URL(string: urlStr) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let data = try JSONEncoder().encode(requestBody)
            request.httpBody = data
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            if !(200...299).contains(statusCode) {
                let errorString = data != nil ? String(data: data!, encoding: .utf8) ?? "No data available" : "No data available"
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(statusCode)", "ResponseBody": errorString])
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ReferralResponse.self, from: data)
                completion(.success(response))
            } catch {
                print("ERROR DURING decoding response: \(error)")
                print("raw response data: \(String(data: data, encoding: .utf8)!)")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Redeem Referral Points
    func redeemReferralPoints(requestBody: RedeemPointsRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: endpoints.redeemReferralPoints) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        do {
            let data = try JSONEncoder().encode(requestBody)
            request.httpBody = data
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("Redeem points status code: \(statusCode)")
            print("Redeem points response: \(String(data: data ?? Data(), encoding: .utf8)!)")
            print("Redeem points response: \(String(describing: response))")
            
            if !(200...299).contains(statusCode) {
                let errorString = data != nil ? String(data: data!, encoding: .utf8) ?? "No data available" : "No data available"
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "\(statusCode) Please try again later", "ResponseBody": errorString])
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
}

struct CreateUserRequest: Codable {
    let secret: String
}

struct CreatedUserResponse: Codable {
    let id: Int
    let referralCode: String
    let points: Int
}

struct User: Codable {
    let id: Int
    let referralCode: String
    let points: Int
    let secret: String
}

struct ReferralRequest: Codable {
    let ownerReferralCode: String // user supposed to input this manually
    let inviteeReferralCode: String
    let secret: String
}

struct ReferralResponse: Codable {
    let points: Int
    let wasReferred: Bool
    let updatedAt: String
}

struct ReferralPointsRequest: Codable {
    let referralCode: String
    let secret: String
}

struct RedeemPointsRequest: Codable {
    let referralCode: String
    let secret: String
    let points: Int
}

//
//  SendThreshold.swift
//  EthGasTracker
//
//  Created by Tem on 4/14/23.
//
import Foundation

func sendThresholdPrice(action: String, deviceToken: String, threshold: String, comparison: String, mute_duration: Int, completion: @escaping (Result<[Threshold], Error>) -> Void) {
    guard let thresholdDouble = Double(threshold) else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid threshold input"])))
        return
    }
    
    let url = URL(string: "http://65.109.175.89:8000/set_threshold")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let data = ["action": action, "device_token": deviceToken, "threshold_price": thresholdDouble, "comparison": comparison, "mute_duration": mute_duration] as [String : Any]
    
    print("received ", data)
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
    } catch {
        completion(.failure(error))
        return
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        if let data = data {
            let responseObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let success = responseObject?["success"] as? Bool, success {
                print(responseObject)
                if let thresholdsArray = responseObject?["thresholds"] as? [[String: Any]] {
                    var newThresholds: [Threshold] = []
                    for thresholdDict in thresholdsArray {
                        if let thresholdPrice = thresholdDict["price"] as? Double,
                           let comparison = thresholdDict["comparison"] as? String,
                           let mute_duration = thresholdDict["mute_duration"] as? Int {
                            let threshold = Threshold( thresholdPrice: thresholdPrice, comparison: comparison, mute_duration: mute_duration, enabled: true)
                            newThresholds.append(threshold)
                        }
                    }
                    completion(.success(newThresholds))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to set threshold price inner"])))
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to set threshold price outer"])))
            }
        }

    }.resume()
}
